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

  # TODO: Add subroutine-encounter tuning constants here (all encounter tuning lives in
  # this module — "Tuning is content"). These are deliberately starter values to tune
  # for feel once the slice is playable:
  #   @sentry_bleed 4         — Trace added per still-alive Sentry, each turn (the clock)
  #   @trap_trace_multiplier 2 — multiplies a turn's Trace when a non-Probe action
  #                              MISMATCHES a :trap subroutine (Probe is exempt)
  # Match/mismatch Progress+Trace come from the program profile (see act/4 TODO):
  # a matching action uses the program's `on_weakness` profile, a mismatch uses its
  # base {progress, trace}. No new constant needed for those.

  # TODO: Add @mastery_keys threshold for the per-subroutine key reveal. Reuse the
  # existing @mastery_weakness value (3) — the old single-layer "weakness" tell is now
  # the per-subroutine `key`, revealed at the same mastery stage. Either rename usages
  # to read clearly or alias @mastery_keys to @mastery_weakness; do not introduce a new
  # number.

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

  # TODO: When the layer model changes to subroutine stacks (see IceNode TODO),
  # begin_encounter must initialize the Encounter's `subroutine_progress` to a zeroed
  # map for the resumed layer: %{subroutine.id => 0} for each subroutine on
  # layer Enum.at(node.layers, start). Everything else here (start = banked_layer + 1,
  # the already_cracked / hardened guards, the clear_hardened effect) stays as-is.
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

  # TODO: Change the signature to act/4 — act(%Encounter{}, player, action, subroutine_id)
  # — because a turn now targets one subroutine on the open board. Resolution per turn:
  #   1. Find the targeted subroutine on the current layer by subroutine_id. If it's not
  #      on the layer or already down, return {:error, :invalid_target}.
  #   2. matched? = the action's key == subroutine.key. Program key is its `:action`
  #      field; Probe is typeless and NEVER matches (always a neutral mismatch, but it is
  #      EXEMPT from the Trap penalty — the careful poke).
  #   3. Pick the action's {progress, trace} profile: matched -> program.on_weakness,
  #      mismatch -> program base {progress, trace}. Probe uses @probe_progress/@probe_trace.
  #   4. Add `progress` to that subroutine's entry in encounter.subroutine_progress.
  #   5. Trace for the turn = round(profile.trace * layer.trace_multiplier), then if it was
  #      a non-Probe MISMATCH against a :trap subroutine, multiply by @trap_trace_multiplier;
  #      then jitter/1 it. Add @sentry_bleed once for EACH :sentry subroutine still alive on
  #      the layer (evaluate "alive" AFTER step 4, so a sentry you just downed stops bleeding).
  #   6. Hand the updated subroutine_progress map + new_trace to resolve/3 (see its TODO).
  # Keep the {:error, :program_not_owned} / {:error, :unknown_action} guards from profile/3.
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

  defp profile(:unknown, _player, _layer), do: {:error, :unknown_action}

  # TODO: The match is no longer layer-level — it's per targeted subroutine (action key vs
  # subroutine.key), so the `program.action == layer.weakness` decision moves OUT of here and
  # INTO act/4 (which knows the target). Restructure profile/3 to just resolve ownership and
  # hand back BOTH profiles so the caller can pick: return {:ok, %{action: program.action,
  # base: %{progress: program.progress, trace: program.trace}, on_weakness: program.on_weakness}}
  # for a {:program, id}, and an equivalent typeless shape for :probe. Keep
  # {:error, :program_not_owned} and {:error, :unknown_action}.
  # NOTE: act/4 must additionally gate {:program, id} on the program being in the player's
  # equipped loadout (ghostwork_state["loadout"]), not merely owned — only the 3 equipped
  # programs are runnable in an encounter. Return {:error, :not_equipped} otherwise.
  defp profile({:program, id}, player, layer) do
    if Map.get(player.inventory, id, 0) >= 1 do
      program = Shunt.Ghostwork.Programs.fetch!(id)

      if program.action == layer.weakness,
        do: {:ok, program.on_weakness},
        else: {:ok, %{progress: program.progress, trace: program.trace}}
    else
      {:error, :program_not_owned}
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

  # TODO: Rework resolve to take the updated subroutine_progress map instead of a single
  # new_progress int: resolve(%Encounter{}, layer, new_subroutine_progress, new_trace).
  #   * Bust clause (new_trace >= @trace_bust) is UNCHANGED — keep it first.
  #   * Layer-cleared clause replaces the `new_progress >= layer.progress_required` guard:
  #     fires when EVERY subroutine on the layer is down (its entry in
  #     new_subroutine_progress >= that subroutine's progress_required). Same effects
  #     (layer.reward ++ mastery+1 ++ bank_layer) and same advance logic (next layer ->
  #     :active with a FRESH zeroed subroutine_progress for the next layer, or :cracked on
  #     the last layer). Carry `trace`.
  #   * Default clause: store the updated subroutine_progress (layer not yet done), carry
  #     trace, no effects.
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

  # TODO: Rename/repurpose for the new model — at this mastery stage the per-subroutine
  # `key` (the old "weakness" tell, now one per subroutine) is un-redacted in the encounter
  # view. Either keep this name and let IceTerminal call it to decide whether to show each
  # subroutine.key, or rename to keys_known?/1; pick one and update callers. Threats
  # (:barrier/:sentry/:trap) are ALWAYS visible and are not gated by this.
  def weakness_known?(encounter), do: encounter.mastery >= @mastery_weakness

  # TODO: Add loadout helpers (3-slot equipped program set; @loadout_slots 3):
  #   * loadout(player) -> the list of equipped program ids from
  #     ghostwork_state["loadout"] (default []).
  #   * equip(player, program_id) / unequip(player, program_id) -> return the new loadout
  #     list to dispatch via the {:ghostwork_loadout, ids} effect (see Effects TODO).
  #     equip is a no-op past @loadout_slots or for an unowned program; both dedupe.
  #   These return the id list for the LiveView to dispatch; they do NOT mutate the player.
  #   The "runnable in an encounter" listing (owned ∩ equipped) lives in Programs (see TODO).
end
