defmodule Shunt.Ghostwork do
  @moduledoc """
  Ghostwork context: the pure ICE-breaking encounter engine.

  All randomness lives here (global `:rand`, like `Shunt.Npcs.Loyalty`) so the
  LiveView stays deterministic. Each entry point returns an updated
  `%Shunt.Ghostwork.Encounter{}` plus the effects the caller must dispatch through
  `Shunt.Players` — the LiveView never computes progress/trace/outcomes itself.

  See priv/docs/SHUNT_ghostwork_v1.md ("The ICE Encounter").
  """

  alias Shunt.Ghostwork.Encounter

  # --- Tuning constants (all encounter tuning lives here; see doc "Tuning is content") ---

  # Probe: innate, always-available action — small Progress, small Trace.
  @probe_progress 3
  @probe_trace 4

  # Bust threshold: Trace at/above this ends the encounter as a bust.
  @trace_bust 100

  # Bust Heat = base + per-layer * layer_index (deeper busts hurt more).
  @bust_heat_base 12
  @bust_heat_per_layer 4

  # Mastery fog-of-war thresholds (per-family crack count).
  @mastery_numbers 1
  @mastery_weakness 3

  # Heat applied by every scan (scanning is mildly loud, like Crafting.scavenge).
  @scan_heat 4

  # Earned-title milestones (doc "Progression"): a ghostwork tree tier is earned when the
  # player holds a deck AND total cracks (sum of all family mastery) reaches the threshold.
  # Tuning only — adjust freely. T1 "Feed Skimmer" is earned just by jacking in.
  @title_thresholds %{1 => 0, 2 => 1, 3 => 3, 4 => 7, 5 => 15}

  # TODO: nodes_at(player, location_id) -> [%{node: %IceNode{}, status: :breakable | :hardened}].
  #   The deck is location-aware: every IceNode (Shunt.Ghostwork.IceNode.all/0) whose
  #   :location_id == location_id, whose :requirements pass (Shunt.Requirements.met?/2), and
  #   that is not fully cracked (banked_layer + 1 < length(layers); banked_layer default -1 from
  #   player.ghostwork_state["nodes"][id]). status is :hardened when the node is hardened AND
  #   player.heat >= node.cool_threshold (can't break now), otherwise :breakable.

  # TODO: fog_stage(mastery_count) -> :dark | :numbers | :weakness, from @mastery_numbers /
  #   @mastery_weakness (the same thresholds numbers_known?/weakness_known? use, but keyed off a
  #   raw count for the Codex readout, which has no live encounter).

  # TODO: mastery_summary(player) -> [%{family: String.t, cracks: integer, fog_stage: atom}] for
  #   each family in player.ghostwork_state["mastery"], sorted by family. Drives the Codex.

  # TODO: titles(player) -> [%{tier: integer, name: String.t, earned?: boolean}] from the
  #   ghostwork skill tree's :tiers (Shunt.Skills.Catalog.fetch!("ghostwork")). earned? is true
  #   when the player holds the deck (tree.tool_key in inventory, count >= 1) AND total cracks
  #   (sum of player.ghostwork_state["mastery"] values) >= @title_thresholds[tier].

  # TODO: lattice_active?(player, location) -> boolean for the MovementLive "⌁ LATTICE" cue:
  #   the location map has a :lattice key AND the player holds the deck (ghostwork tree.tool_key
  #   in inventory, count >= 1).

  def scan(player, location) do
    case Map.fetch(location, :lattice) do
      :error ->
        {:error, :no_lattice}

      {:ok, lattice} ->
        leads = Map.get(lattice, :leads, [])
        filler = Map.get(lattice, :filler, [])

        case Enum.find(leads, &available_lead?(&1, player)) do
          nil ->
            resolve_scan(filler)

          lead ->
            {:ok, lead.on_intercept ++ [{:heat, @scan_heat}],
             %{kind: :lead, signal_id: lead.id, text: lead.text}}
        end
    end
  end

  defp available_lead?(lead, player) do
    Shunt.Requirements.met?(player, lead.requirements) and
      Enum.any?(lead.on_intercept, fn
        {:knowledge, key} -> key not in player.knowledge
        _ -> false
      end)
  end

  defp resolve_scan([]), do: {:ok, [{:heat, @scan_heat}], %{kind: :empty, text: nil}}

  defp resolve_scan(filler) do
    chosen = weighted_pick(filler)
    {:ok, chosen.on_intercept ++ [{:heat, @scan_heat}], %{kind: :filler, text: chosen.text}}
  end

  defp weighted_pick(items) do
    total = Enum.sum(Enum.map(items, & &1.weight))
    pick(items, :rand.uniform(total))
  end

  defp pick([item | rest], roll) do
    if roll <= item.weight, do: item, else: pick(rest, roll - item.weight)
  end

  def begin_encounter(player, node) do
    state = Map.get(player.ghostwork_state, "nodes", %{})
    node_state = Map.get(state, node.id, %{"banked_layer" => -1, "hardened" => false})
    start = Map.get(node_state, "banked_layer", -1) + 1

    cond do
      start >= length(node.layers) ->
        {:error, :already_cracked}

      Map.get(node_state, "hardened", false) and player.heat >= node.cool_threshold ->
        {:error, :hardened}

      true ->
        mastery =
          player.ghostwork_state
          |> Map.get("mastery", %{})
          |> Map.get(node.family, 0)

        effects =
          if Map.get(node_state, "hardened", false),
            do: [{:ghostwork_node, node.id, :clear_hardened}],
            else: []

        encounter = %Encounter{node: node, layer_index: start, mastery: mastery}
        {:ok, encounter, effects}
    end
  end

  def act(%Encounter{} = encounter, player, action) do
    layer = Enum.at(encounter.node.layers, encounter.layer_index)

    case profile(action, player, layer) do
      {:error, reason} ->
        {:error, reason}

      {:ok, profile} ->
        new_progress = encounter.progress + profile.progress
        trace_base = round(profile.trace * layer.trace_multiplier)
        new_trace = encounter.trace + jitter(trace_base)

        {updated, effects} = resolve(encounter, layer, new_progress, new_trace)
        {:ok, updated, effects}
    end
  end

  defp profile(:probe, _player, _layer),
    do: {:ok, %{progress: @probe_progress, trace: @probe_trace}}

  defp profile({:program, id}, player, layer) do
    program = Shunt.Ghostwork.Programs.fetch!(id)

    cond do
      not Enum.any?(Shunt.Ghostwork.Programs.owned(player), &(&1.id == id)) ->
        {:error, :program_not_owned}

      program.action == layer.weakness ->
        {:ok, program.on_weakness}

      true ->
        {:ok, %{progress: program.progress, trace: program.trace}}
    end
  end

  defp jitter(trace_base) do
    spread = max(1, div(trace_base, 2))
    Enum.random(max(1, trace_base - spread)..(trace_base + spread))
  end

  defp resolve(%Encounter{} = encounter, _layer, _new_progress, new_trace)
       when new_trace >= @trace_bust do
    effects = [
      {:heat, bust_heat(encounter.layer_index)},
      {:ghostwork_node, encounter.node.id, :harden}
    ]

    {%{encounter | status: :busted, trace: @trace_bust}, effects}
  end

  defp resolve(%Encounter{} = encounter, layer, new_progress, new_trace)
       when new_progress >= layer.progress_required do
    node = encounter.node

    effects =
      layer.reward ++
        [
          {:ghostwork_mastery, node.family, 1},
          {:ghostwork_node, node.id, {:bank_layer, encounter.layer_index}}
        ]

    next_index = encounter.layer_index + 1

    updated =
      if next_index >= length(node.layers) do
        %{encounter | status: :cracked, progress: 0, trace: new_trace}
      else
        %{encounter | layer_index: next_index, progress: 0, trace: new_trace}
      end

    {updated, effects}
  end

  defp resolve(%Encounter{} = encounter, _layer, new_progress, new_trace) do
    {%{encounter | progress: new_progress, trace: new_trace}, []}
  end

  defp bust_heat(layer_index), do: @bust_heat_base + @bust_heat_per_layer * layer_index

  def retreat(%Encounter{} = encounter), do: {:ok, %{encounter | status: :retreated}, []}

  def numbers_known?(encounter), do: encounter.mastery >= @mastery_numbers

  def weakness_known?(encounter), do: encounter.mastery >= @mastery_weakness
end
