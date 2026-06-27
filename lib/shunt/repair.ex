defmodule Shunt.Repair do
  @moduledoc """
  Repair economy context for Street Alchemy. Pure functions over player state +
  :repairables content. Returns effect lists for Players.dispatch and explicit
  result metadata (never requires the caller to diff before/after state).
  """

  # TODO: implement `state(player, repairable_id)` returning the current state string —
  #   Map.get(player.infrastructure, repairable_id) || the repairable's initial_state
  #   (look up via Shunt.Content.fetch!(:repairables, repairable_id)). This is the single
  #   source of truth used by Shunt.Requirements {:infra_state, ...} and the UI.

  # TODO: implement `at_location(player, location_id)` returning the %Repairable{} structs
  #   whose location_id matches, for surfacing as POIs. Use Shunt.Content.all(:repairables).

  # TODO: implement `inspect(player, repairable)` returning the diagnosis text of the
  #   deepest entry in repairable.inspect_tiers whose requirements are met via
  #   Shunt.Requirements.met?/2. Always succeeds (tier 0 has empty requirements).

  # TODO: implement `available_solutions(player, repairable)` returning the solutions
  #   whose `from` includes the current state AND Shunt.Requirements.met?(player,
  #   requirements) AND the player's inventory covers every {key, qty} in `consumes`.

  # TODO: implement `repair(player, repairable_id, solution_id)`:
  #   - {:error, :invalid_solution} if solution_id not in the repairable
  #   - {:error, :wrong_state} if current state not in solution.from
  #   - {:error, :insufficient_materials} if requirements unmet or inventory lacks consumes
  #   - otherwise {:ok, effects, %{from: state, to: result_state, outcome_text: text}} where
  #     effects = [{:inventory, k, -qty} for each consumes] ++
  #               [{:infrastructure, repairable_id, result_state}] ++ solution.effects
  #     (solution.effects is where SA progress / :modify_rep / :discover_location /
  #     :knowledge unlocks live — all existing effect types).

  # --- Slice content to author (priv/), removed as each lands; follow the Content
  #     Constitution / Terminology / Style / Naming / Lexicon docs ---
  #
  # TODO: priv/content/repairables/shunt9_power_relay_generator.exs — a %Repairable{} on
  #   "shunt9_power_relay" (NPC Coil), initial_state "broken", 4 inspect_tiers (none →
  #   soldering iron → diagnostic_probe → precision_toolkit), 3 solutions (improvised_relay →
  #   patched; standard_relay → repaired +rep; military_relay → repaired + extra world benefit),
  #   and state_descriptions for "patched"/"repaired". A repaired/military solution effect
  #   should unlock a new exit/POI (pick a concrete target from the shunt9 graph) via an
  #   {:infra_state, "shunt9_power_relay_generator", "repaired"} requirement on that exit/event.
  #
  # TODO: priv/content/recipes — add the relay parts (improvised_relay, standard_relay,
  #   military_relay) consumed by solutions, plus the persistent tools diagnostic_probe and
  #   precision_toolkit used as non-consumed :has_item gates (tier_required as appropriate).
  #
  # TODO: a Coil conditional_event referencing the failing generator, gated
  #   {:infra_state, "shunt9_power_relay_generator", "broken"}, added to Coil's
  #   conditional_events so an NPC naturally surfaces the problem.
end
