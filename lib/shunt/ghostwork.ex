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
  @bust_heat_base 8
  @bust_heat_per_layer 3

  # Mastery fog-of-war thresholds (per-family crack count).
  @mastery_numbers 1
  @mastery_weakness 3

  # Heat applied by every scan (scanning is mildly loud, like Crafting.scavenge).
  @scan_heat 2

  # Subroutine-encounter tuning (starter values, tune for feel once playable).
  # Trace added per still-alive Sentry, each turn it remains alive (the clock).
  @sentry_bleed 4
  # Multiplies a turn's Trace when a non-Probe action MISMATCHES a :trap subroutine.
  @trap_trace_multiplier 2

  # Equipped-program slots: only these are runnable in an encounter (the prep decision).
  @loadout_slots 3

  # Earned-title milestones (doc "Progression"): a ghostwork tree tier is earned when the
  # player holds a deck AND total cracks (sum of all family mastery) reaches the threshold.
  # Tuning only — adjust freely. T1 "Feed Skimmer" is earned just by jacking in.
  @title_thresholds %{1 => 0, 2 => 1, 3 => 3, 4 => 7, 5 => 15}

  def nodes_at(player, location_id) do
    nodes = Map.get(player.ghostwork_state, "nodes", %{})
    mastery = Map.get(player.ghostwork_state, "mastery", %{})

    Shunt.Ghostwork.IceNode.all()
    |> Enum.filter(fn node ->
      node.location_id == location_id and Shunt.Requirements.met?(player, node.requirements) and
        not fully_cracked?(nodes, node)
    end)
    |> Enum.map(fn node ->
      %{
        node: node,
        status: node_status(nodes, node, player.heat),
        read: fog_stage(Map.get(mastery, node.family, 0))
      }
    end)
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

  def lattice_active?(player, location, tool_key \\ nil) do
    key = tool_key || Shunt.Skills.Catalog.fetch!("ghostwork").tool_key
    Map.has_key?(location, :lattice) and Map.get(player.inventory, key, 0) >= 1
  end

  def progress_percent(progress, required) when required > 0,
    do: min(100, round(progress / required * 100))

  def progress_percent(_progress, _required), do: 0

  def scan(player, location) do
    tree = Shunt.Skills.Catalog.fetch!("ghostwork")
    deck? = Map.get(player.inventory, tree.tool_key, 0) >= 1

    cond do
      not deck? ->
        {:error, :no_deck}

      not Map.has_key?(location, :lattice) ->
        {:error, :no_lattice}

      true ->
        lattice = Map.fetch!(location, :lattice)
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
    Shunt.Requirements.met?(player, lead.requirements) and not swept?(lead, player)
  end

  defp swept?(lead, player) do
    case Enum.filter(lead.on_intercept, &match?({:knowledge, _}, &1)) do
      [] -> false
      kfx -> Enum.all?(kfx, fn {:knowledge, key} -> key in player.knowledge end)
    end
  end

  defp resolve_scan([]), do: {:ok, [{:heat, @scan_heat}], %{kind: :empty, text: nil}}

  defp resolve_scan(filler) do
    case Enum.filter(filler, &(&1.weight > 0)) do
      [] ->
        resolve_scan([])

      available ->
        chosen = weighted_pick(available)
        {:ok, chosen.on_intercept ++ [{:heat, @scan_heat}], %{kind: :filler, text: chosen.text}}
    end
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

        encounter = %Encounter{
          node: node,
          layer_index: start,
          mastery: mastery,
          subroutine_progress: zeroed_board(node, start)
        }

        {:ok, encounter, effects}
    end
  end

  defp zeroed_board(node, layer_index) do
    node.layers
    |> Enum.at(layer_index)
    |> Map.fetch!(:subroutines)
    |> Map.new(&{&1.id, 0})
  end

  @doc """
  Run one action against one subroutine on the current layer's open board.

  `subroutine_id` defaults to the first still-alive subroutine (so single-subroutine
  nodes and a UI without target selection still work). The turn:

    1. resolve ownership / target validity,
    2. matched? = action key == subroutine.key (Probe is typeless and never matches),
    3. add the matched/mismatched Progress profile to that subroutine,
    4. add the action's Trace (Trap amplifies a mismatched non-Probe hit) plus a bleed
       for every Sentry still alive AFTER the hit,
    5. resolve into a downed subroutine / banked layer / cracked node / bust.
  """
  def act(%Encounter{} = encounter, player, action, subroutine_id \\ nil) do
    layer = Enum.at(encounter.node.layers, encounter.layer_index)

    with {:ok, prof} <- profile(action, player),
         {:ok, target} <- target_subroutine(encounter, layer, subroutine_id) do
      matched? = prof.action != nil and prof.action == target.key
      gained = if(matched?, do: prof.on_weakness, else: prof.base)

      new_board =
        Map.update(
          encounter.subroutine_progress,
          target.id,
          gained.progress,
          &(&1 + gained.progress)
        )

      new_trace = encounter.trace + turn_trace(gained.trace, layer, prof, target, new_board)

      {updated, effects} = resolve(encounter, layer, new_board, new_trace)
      {:ok, updated, effects}
    end
  end

  @doc """
  The subroutine the UI should target next: the `preferred` id if it is still alive on the
  current layer, otherwise the first still-alive subroutine, otherwise nil (encounter ended
  or layer cleared). Lets the LiveView keep its highlight on a subroutine across turns
  without itself knowing what "alive" means.
  """
  def resolve_target(%Encounter{status: :active} = encounter, preferred) do
    layer = Enum.at(encounter.node.layers, encounter.layer_index)
    alive = Enum.filter(layer.subroutines, &alive?(&1, encounter.subroutine_progress))

    cond do
      Enum.any?(alive, &(&1.id == preferred)) -> preferred
      alive == [] -> nil
      true -> hd(alive).id
    end
  end

  def resolve_target(%Encounter{}, _preferred), do: nil

  defp turn_trace(base_trace, layer, prof, target, new_board) do
    trapped? = prof.action != nil and target.threat == :trap and prof.action != target.key
    scaled = round(base_trace * layer.trace_multiplier)
    scaled = if trapped?, do: scaled * @trap_trace_multiplier, else: scaled

    jitter(scaled) + @sentry_bleed * alive_sentries(layer, new_board)
  end

  defp alive_sentries(layer, board) do
    Enum.count(layer.subroutines, fn sub ->
      sub.threat == :sentry and Map.get(board, sub.id, 0) < sub.progress_required
    end)
  end

  defp target_subroutine(encounter, layer, nil) do
    case Enum.find(layer.subroutines, &alive?(&1, encounter.subroutine_progress)) do
      nil -> {:error, :invalid_target}
      sub -> {:ok, sub}
    end
  end

  defp target_subroutine(encounter, layer, id) do
    case Enum.find(layer.subroutines, &(&1.id == id)) do
      nil ->
        {:error, :invalid_target}

      sub ->
        if alive?(sub, encounter.subroutine_progress),
          do: {:ok, sub},
          else: {:error, :invalid_target}
    end
  end

  defp alive?(sub, board), do: Map.get(board, sub.id, 0) < sub.progress_required

  # Probe is typeless (action: nil) so it never matches a subroutine's key.
  defp profile(:probe, _player),
    do: {:ok, %{action: nil, base: probe_profile(), on_weakness: probe_profile()}}

  defp profile(:unknown, _player), do: {:error, :unknown_action}

  defp profile({:program, id}, player) do
    if Map.get(player.inventory, id, 0) >= 1 do
      program = Shunt.Ghostwork.Programs.fetch!(id)

      {:ok,
       %{
         action: program.action,
         base: %{progress: program.progress, trace: program.trace},
         on_weakness: program.on_weakness
       }}
    else
      {:error, :program_not_owned}
    end
  end

  defp jitter(trace_base) do
    spread = max(1, div(trace_base, 2))
    Enum.random(max(1, trace_base - spread)..(trace_base + spread))
  end

  defp resolve(%Encounter{} = encounter, _layer, _new_board, new_trace)
       when new_trace >= @trace_bust do
    effects = [
      {:heat, bust_heat(encounter.layer_index)},
      {:ghostwork_node, encounter.node.id, :harden}
    ]

    {%{encounter | status: :busted, trace: @trace_bust}, effects}
  end

  defp resolve(%Encounter{} = encounter, layer, new_board, new_trace) do
    if layer_cleared?(layer, new_board) do
      bank_layer(encounter, layer, new_trace)
    else
      {%{encounter | subroutine_progress: new_board, trace: new_trace}, []}
    end
  end

  defp layer_cleared?(layer, board) do
    Enum.all?(layer.subroutines, &(not alive?(&1, board)))
  end

  defp bank_layer(%Encounter{} = encounter, layer, new_trace) do
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
        %{encounter | status: :cracked, trace: new_trace}
      else
        %{
          encounter
          | layer_index: next_index,
            subroutine_progress: zeroed_board(node, next_index),
            trace: new_trace
        }
      end

    {updated, effects}
  end

  defp bust_heat(layer_index), do: @bust_heat_base + @bust_heat_per_layer * layer_index

  def retreat(%Encounter{} = encounter), do: {:ok, %{encounter | status: :retreated}, []}

  @doc "The innate Probe action's base profile, for the encounter UI readout."
  def probe_profile, do: %{progress: @probe_progress, trace: @probe_trace}

  def numbers_known?(encounter), do: encounter.mastery >= @mastery_numbers

  @doc """
  At this mastery stage the per-subroutine `key` (the old "weakness" tell, now one per
  subroutine) is un-redacted in the encounter view. Threats (:barrier/:sentry/:trap) are
  always visible and are not gated by this.
  """
  def weakness_known?(encounter), do: encounter.mastery >= @mastery_weakness

  @doc "The player's equipped program ids (the 3-slot encounter loadout)."
  def loadout(player), do: Map.get(player.ghostwork_state, "loadout", [])

  @doc """
  The new loadout list with `program_id` equipped — for the caller to dispatch via the
  `{:ghostwork_loadout, ids}` effect. A no-op if the program isn't owned, is already
  equipped, or all #{@loadout_slots} slots are full. Does not mutate the player.
  """
  def equip(player, program_id) do
    current = loadout(player)
    owned? = Map.get(player.inventory, program_id, 0) >= 1

    if owned? and program_id not in current and length(current) < @loadout_slots,
      do: current ++ [program_id],
      else: current
  end

  @doc "The new loadout list with `program_id` removed, for the caller to dispatch."
  def unequip(player, program_id), do: loadout(player) -- [program_id]
end
