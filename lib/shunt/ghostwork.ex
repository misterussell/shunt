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

  # Equipped-program slots come from the player's active deck (see deck_slots/1). This is the
  # fallback when no deck is owned — unreachable in an encounter (you can't jack in without a
  # deck), but keeps equip/2 total.
  @default_slots 3

  # Lockout: tripping a vault's defender is harsher than a Trace-bust. Base + per-layer, like
  # bust heat but larger (deeper vaults hurt more). Tuning only.
  @lockout_heat_base 15
  @lockout_heat_per_layer 6

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

  @doc """
  How well the player reads a family, as a 3-rung ladder the codex renders directly:
  SEEN → COSTS → KEYS. `filled` is how many rungs are lit (1..3); `to_keys` is how many more
  cracks until the top rung (0 once there). Replaces the old opaque "P/T mapped" / "weakness" fog
  tags with one legible climb driven by the same @mastery_numbers/@mastery_weakness thresholds.
  """
  def read_meter(cracks) when cracks >= @mastery_weakness,
    do: %{stage: :keys, filled: 3, label: "KEYS", to_keys: 0}

  def read_meter(cracks) when cracks >= @mastery_numbers,
    do: %{stage: :costs, filled: 2, label: "COSTS", to_keys: @mastery_weakness - cracks}

  def read_meter(cracks),
    do: %{stage: :seen, filled: 1, label: "SEEN", to_keys: @mastery_weakness - cracks}

  def mastery_summary(player) do
    player.ghostwork_state
    |> Map.get("mastery", %{})
    |> Enum.sort_by(fn {family, _} -> family end)
    |> Enum.map(fn {family, cracks} ->
      %{family: family, cracks: cracks, read: read_meter(cracks)}
    end)
  end

  @doc """
  The codex: `mastery_summary/1` plus, for each family the player has read to KEYS, a `coverage`
  list of which action keys that family's ICE demands and which of the player's owned programs
  answer them. `coverage` is nil below KEYS (you haven't learned the keys yet, so nothing to show).
  """
  def codex(player) do
    Enum.map(mastery_summary(player), fn entry ->
      coverage =
        if entry.read.stage == :keys, do: family_coverage(player, entry.family), else: nil

      Map.put(entry, :coverage, coverage)
    end)
  end

  @doc """
  The distinct action keys demanded by a family's ICE (across every subroutine of every node in
  the family, vaults included), sorted, each paired with the name of an owned program that
  counters it (or nil). The actionable half of the codex: "this family wants ▷decrypt — do you
  carry one?"
  """
  def family_coverage(player, family) do
    owned = Map.new(Shunt.Ghostwork.Programs.owned(player), &{&1.action, &1.name})

    Shunt.Ghostwork.IceNode.all()
    |> Enum.filter(&(&1.family == family))
    |> Enum.flat_map(fn node -> Enum.flat_map(node.layers, & &1.subroutines) end)
    |> Enum.map(& &1.key)
    |> Enum.reject(&is_nil/1)
    |> Enum.uniq()
    |> Enum.sort()
    |> Enum.map(&%{key: &1, program: Map.get(owned, &1)})
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

  A subroutine may carry `threat: :vault` plus its own `reward: [...]` — an OPTIONAL, richer
  target (it never blocks the layer's safe reward). The one rule: a vault advances ONLY when hit
  with its matching key. A vault hit with any other action (probe — typeless — or a mismatched
  program) trips the defender: the encounter ends `:locked_out` (heavier Heat than a bust + node
  hardened; deeper unbanked layers are forfeited because the encounter ends). Vaults are never
  auto-targeted (see target_subroutine/3), so a lockout only ever follows a deliberate mis-hit.
  """
  def act(%Encounter{} = encounter, player, action, subroutine_id \\ nil) do
    layer = Enum.at(encounter.node.layers, encounter.layer_index)

    with {:ok, prof} <- profile(action, player),
         {:ok, target} <- target_subroutine(encounter, layer, subroutine_id) do
      matched? = prof.action != nil and prof.action == target.key

      if target.threat == :vault and not matched? do
        lockout(encounter)
      else
        apply_hit(encounter, layer, prof, target, matched?)
      end
    end
  end

  defp apply_hit(%Encounter{} = encounter, layer, prof, target, matched?) do
    gained = if(matched?, do: prof.on_weakness, else: prof.base)

    new_board =
      Map.update(
        encounter.subroutine_progress,
        target.id,
        gained.progress,
        &(&1 + gained.progress)
      )

    new_trace = encounter.trace + turn_trace(gained.trace, layer, prof, target, new_board)
    vault_reward = vault_cracked_reward(target, encounter.subroutine_progress, new_board)

    {updated, effects} = resolve(encounter, layer, new_board, new_trace, vault_reward)
    {:ok, updated, effects}
  end

  # A vault just cracked this turn (was alive, now down) → its reward fires. A Trace-bust denies
  # it (handled in resolve/5, which ignores vault_reward on the bust clause).
  defp vault_cracked_reward(%{threat: :vault} = vault, old_board, new_board) do
    was_alive = Map.get(old_board, vault.id, 0) < vault.progress_required
    now_down = Map.get(new_board, vault.id, 0) >= vault.progress_required
    if was_alive and now_down, do: Map.get(vault, :reward, []), else: []
  end

  defp vault_cracked_reward(_target, _old_board, _new_board), do: []

  defp lockout(%Encounter{} = encounter) do
    effects = [
      {:heat, lockout_heat(encounter.layer_index)},
      {:ghostwork_node, encounter.node.id, :harden}
    ]

    {:ok, %{encounter | status: :locked_out}, effects}
  end

  defp lockout_heat(layer_index), do: @lockout_heat_base + @lockout_heat_per_layer * layer_index

  @doc """
  The subroutine the UI should target next: the `preferred` id if it is still alive on the
  current layer, otherwise the first still-alive subroutine, otherwise nil (encounter ended
  or layer cleared). Lets the LiveView keep its highlight on a subroutine across turns
  without itself knowing what "alive" means.
  """
  # Auto-target never picks a vault (that would risk an accidental lockout): a selected-alive
  # subroutine of any kind keeps the highlight, but the fallback only ever lands on a non-vault.
  def resolve_target(%Encounter{status: :active} = encounter, preferred) do
    layer = Enum.at(encounter.node.layers, encounter.layer_index)
    board = encounter.subroutine_progress
    preferred_alive? = Enum.any?(layer.subroutines, &(&1.id == preferred and alive?(&1, board)))
    fallback = Enum.find(layer.subroutines, &(&1.threat != :vault and alive?(&1, board)))

    cond do
      preferred_alive? -> preferred
      fallback -> fallback.id
      true -> nil
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
    case Enum.find(
           layer.subroutines,
           &(&1.threat != :vault and alive?(&1, encounter.subroutine_progress))
         ) do
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

  # A Trace-bust is terminal and takes priority over any layer/vault credit this turn (the
  # vault_reward is intentionally dropped here — you got traced out as it cracked).
  defp resolve(%Encounter{} = encounter, _layer, _new_board, new_trace, _vault_reward)
       when new_trace >= @trace_bust do
    effects = [
      {:heat, bust_heat(encounter.layer_index)},
      {:ghostwork_node, encounter.node.id, :harden}
    ]

    {%{encounter | status: :busted, trace: @trace_bust}, effects}
  end

  # Model ii ("cleared but open"): a vault never blocks the safe reward, and it creates a discrete
  # "safe now — drill the vault or descend?" beat. Vault-LESS layers advance immediately, exactly
  # as before (required cleared + no vault → advance).
  defp resolve(%Encounter{} = encounter, layer, new_board, new_trace, vault_reward) do
    cond do
      required_cleared?(layer, new_board) and not alive_vault?(layer, new_board) ->
        {updated, bank} = advance(encounter, layer, new_board, new_trace)
        {updated, vault_reward ++ bank}

      required_cleared?(layer, new_board) and not encounter.layer_banked ->
        {updated, bank} = bank_and_hold(encounter, layer, new_board, new_trace)
        {updated, vault_reward ++ bank}

      true ->
        {%{encounter | subroutine_progress: new_board, trace: new_trace}, vault_reward}
    end
  end

  defp required_cleared?(layer, board) do
    layer.subroutines
    |> Enum.reject(&(&1.threat == :vault))
    |> Enum.all?(&(not alive?(&1, board)))
  end

  defp alive_vault?(layer, board) do
    Enum.any?(layer.subroutines, &(&1.threat == :vault and alive?(&1, board)))
  end

  # Bank the current layer's safe reward once and hold the layer open for the vault.
  defp bank_and_hold(%Encounter{} = encounter, layer, new_board, new_trace) do
    {%{encounter | subroutine_progress: new_board, trace: new_trace, layer_banked: true},
     bank_effects(encounter, layer)}
  end

  # Move to the next layer (or crack the node). Emits the safe bank effects only if they weren't
  # already banked while the layer was held open.
  defp advance(%Encounter{} = encounter, layer, new_board, new_trace) do
    node = encounter.node
    bank = if encounter.layer_banked, do: [], else: bank_effects(encounter, layer)
    next_index = encounter.layer_index + 1

    updated =
      if next_index >= length(node.layers) do
        %{encounter | status: :cracked, subroutine_progress: new_board, trace: new_trace}
      else
        %{
          encounter
          | layer_index: next_index,
            subroutine_progress: zeroed_board(node, next_index),
            trace: new_trace,
            layer_banked: false
        }
      end

    {updated, bank}
  end

  defp bank_effects(%Encounter{} = encounter, layer) do
    node = encounter.node

    layer.reward ++
      [
        {:ghostwork_mastery, node.family, 1},
        {:ghostwork_node, node.id, {:bank_layer, encounter.layer_index}}
      ]
  end

  defp bust_heat(layer_index), do: @bust_heat_base + @bust_heat_per_layer * layer_index

  def retreat(%Encounter{} = encounter), do: {:ok, %{encounter | status: :retreated}, []}

  @doc """
  Skip a still-alive vault and go deeper — the player's "banked, don't push my luck" choice.
  Valid only on a "cleared but open" layer (required set down, safe reward already banked, a
  vault still alive). Advances to the next layer (re-zeroing the board, carrying Trace) or cracks
  the node on the last layer. Dispatches no effects: the safe reward already banked, the vault is
  forfeited by choice.
  """
  def descend(%Encounter{status: :active, layer_banked: true} = encounter) do
    layer = Enum.at(encounter.node.layers, encounter.layer_index)

    if alive_vault?(layer, encounter.subroutine_progress) do
      {updated, []} = advance(encounter, layer, encounter.subroutine_progress, encounter.trace)
      {:ok, updated, []}
    else
      {:error, :nothing_to_skip}
    end
  end

  def descend(%Encounter{}), do: {:error, :not_banked}

  @doc "Whether the UI should offer DESCEND — the current layer is cleared-but-open on a live vault."
  def descend_available?(%Encounter{status: :active, layer_banked: true} = encounter) do
    layer = Enum.at(encounter.node.layers, encounter.layer_index)
    alive_vault?(layer, encounter.subroutine_progress)
  end

  def descend_available?(%Encounter{}), do: false

  @doc "The innate Probe action's base profile, for the encounter UI readout."
  def probe_profile, do: %{progress: @probe_progress, trace: @probe_trace}

  def numbers_known?(encounter), do: encounter.mastery >= @mastery_numbers

  @doc """
  At this mastery stage the per-subroutine `key` (the old "weakness" tell, now one per
  subroutine) is un-redacted in the encounter view. Threats (:barrier/:sentry/:trap) are
  always visible and are not gated by this.
  """
  def weakness_known?(encounter), do: encounter.mastery >= @mastery_weakness

  @doc """
  The player's active deck — the highest-`slots` deck they own — or nil if they own none.
  Decks are gear (`Shunt.Ghostwork.Decks`); a better deck grants more loadout slots.
  """
  def active_deck(player) do
    case Shunt.Ghostwork.Decks.owned(player) do
      [] -> nil
      decks -> Enum.max_by(decks, & &1.slots)
    end
  end

  @doc "The player's program loadout size — the active deck's slots, or #{@default_slots} if deckless."
  def deck_slots(player) do
    case active_deck(player) do
      nil -> @default_slots
      deck -> deck.slots
    end
  end

  @doc "The player's equipped program ids (the encounter loadout, sized by the active deck)."
  def loadout(player), do: Map.get(player.ghostwork_state, "loadout", [])

  @doc """
  The new loadout list with `program_id` equipped — for the caller to dispatch via the
  `{:ghostwork_loadout, ids}` effect. A no-op if the program isn't owned, is already
  equipped, or every deck slot (see deck_slots/1) is full. Does not mutate the player.
  """
  def equip(player, program_id) do
    current = loadout(player)
    owned? = Map.get(player.inventory, program_id, 0) >= 1

    if owned? and program_id not in current and length(current) < deck_slots(player),
      do: current ++ [program_id],
      else: current
  end

  @doc "The new loadout list with `program_id` removed, for the caller to dispatch."
  def unequip(player, program_id), do: loadout(player) -- [program_id]
end
