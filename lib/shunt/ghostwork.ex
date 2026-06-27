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

  def nodes_at(player, location_id) do
    nodes = Map.get(player.ghostwork_state, "nodes", %{})

    Shunt.Ghostwork.IceNode.all()
    |> Enum.filter(fn node ->
      node.location_id == location_id and Shunt.Requirements.met?(player, node.requirements) and
        not fully_cracked?(nodes, node)
    end)
    |> Enum.map(fn node -> %{node: node, status: node_status(nodes, node, player.heat)} end)
  end

  defp fully_cracked?(nodes, node) do
    banked_layer(nodes, node) + 1 >= length(node.layers)
  end

  defp banked_layer(nodes, node) do
    nodes |> Map.get(node.id, %{}) |> Map.get("banked_layer", -1)
  end

  defp node_status(nodes, node, heat) do
    hardened = nodes |> Map.get(node.id, %{}) |> Map.get("hardened", false)
    if hardened and heat >= node.cool_threshold, do: :hardened, else: :breakable
  end

  def fog_stage(count) when count >= @mastery_weakness, do: :weakness
  def fog_stage(count) when count >= @mastery_numbers, do: :numbers
  def fog_stage(_count), do: :dark

  def mastery_summary(player) do
    player.ghostwork_state
    |> Map.get("mastery", %{})
    |> Enum.sort_by(fn {family, _} -> family end)
    |> Enum.map(fn {family, cracks} ->
      %{family: family, cracks: cracks, fog_stage: fog_stage(cracks)}
    end)
  end

  def titles(player) do
    tree = Shunt.Skills.Catalog.fetch!("ghostwork")
    deck? = Map.get(player.inventory, tree.tool_key, 0) >= 1
    total = player.ghostwork_state |> Map.get("mastery", %{}) |> Map.values() |> Enum.sum()

    Enum.map(tree.tiers, fn tier ->
      earned? = deck? and total >= Map.fetch!(@title_thresholds, tier.tier)
      %{tier: tier.tier, name: tier.name, earned?: earned?}
    end)
  end

  def lattice_active?(player, location) do
    tree = Shunt.Skills.Catalog.fetch!("ghostwork")
    Map.has_key?(location, :lattice) and Map.get(player.inventory, tree.tool_key, 0) >= 1
  end

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

  @doc "The innate Probe action's base profile, for the encounter UI readout."
  def probe_profile, do: %{progress: @probe_progress, trace: @probe_trace}

  def numbers_known?(encounter), do: encounter.mastery >= @mastery_numbers

  def weakness_known?(encounter), do: encounter.mastery >= @mastery_weakness
end
