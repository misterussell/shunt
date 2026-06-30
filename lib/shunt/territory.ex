defmodule Shunt.Territory do
  @moduledoc """
  The Territory ladder: the player's hideout — premises (the shell) + modules (the guts),
  with a derived tier. See priv/docs/SHUNT_territory_ladder_v1.md.

  Domain owner for all Territory logic. LiveViews dispatch commands here and render the
  results; they never compute tier, reservoir, or availability themselves (LiveView
  presentation boundary).

  Persisted state lives on the player: :premises_id, :modules, :last_collected. Premises
  *class* and the *tier* name are derived, never stored (mirrors Shunt.District).
  """

  # alias Shunt.Content
  # alias Shunt.Players.Player
  # alias Shunt.Requirements

  # TODO: [Territory] premises/1 — fetch the player's premises location content
  # (Content.fetch!(:locations, player.premises_id)). premises_class/1 — read its
  # :premises_class field (the premises shell is a location flagged with :premises_class +
  # an optional :relocation block; see §3/§6). Decide the unknown/missing-class behavior:
  # default to class 1 so a player on a non-premises location still resolves sanely.

  # TODO: [Territory] tier/1 — return {n, name} for the deepest ladder tier the player
  # satisfies. Model on Shunt.District.derive for :ordinal facts: fetch the ladder def
  # (Content.fetch!(:territory, "ladder")), scan its tiers ordered DEEPEST-FIRST, return the
  # first whose requirements are all met via Requirements.met?/2, else the default
  # {1, "Squatter"}. Tier requirements use {:has_module, key} / {:premises_at_least, class}.
  # Unit-test: no modules -> Squatter; stash -> Tenant; bleed (with class >=2) -> Operator;
  # drop_point -> Fixture; an unauthored higher-tier keystone never derives.

  # TODO: [Territory] Income math (pure; see §4). All take a fixed `now` so they unit-test
  # without a clock:
  #   income_rate(player)    = sum of rate over installed :income modules
  #   reservoir_cap(player)  = sum of (rate * cap_hours) over installed :income modules
  #   reservoir(player, now) = min(income_rate * elapsed_hours, reservoir_cap) |> floor,
  #     where elapsed_hours = max(0, now - player.last_collected) in fractional hours, and a
  #     nil last_collected yields reservoir 0. Unit-test: nil last_collected -> 0; partial
  #     fill; capping at reservoir_cap; negative elapsed (clock skew) clamps to 0.

  # TODO: [Territory] collect/2 (resolver) — given (player, now):
  #   reservoir == 0 -> {:error, :nothing_to_collect}
  #   take          -> {:ok, [{:scrip, +take}, {:heat, +trace(take)}, {:set, :last_collected, now}]}
  # trace(take) scales Heat to the amount banked (starter tuning ~1 Heat per 30 scrip; read the
  # coefficient from the income module content so it's tunable). Heat routes through Effects.apply
  # -> Heat.resolve, so a greedy collect can trip a Heat event — covered by a Players.Server test,
  # not here. Unit-test the effect list and the :nothing_to_collect guard with a fixed now.

  # TODO: [Territory] install_module/2 (resolver) — given (player, module_key): look up the
  # module def; return {:error, :unknown_module} / {:error, :already_owned} /
  # {:error, :premises_class_too_low} / {:error, :insufficient_scrip|:insufficient_cred} /
  # {:error, :requirements_unmet} as appropriate, else {:ok, effects} = [{:scrip, -cost.scrip},
  # {:cred, -cost.cred}, {:install_module, key}] plus, when the module's effect is :income and
  # player.last_collected is nil, {:set, :last_collected, now} to start accrual (pass `now` in).
  # Unit-test each error branch and the happy path effect list.

  # TODO: [Territory] relocate/2 (resolver) — given (player, premises_location_id): the target
  # must be a location carrying :premises_class and a :relocation block, with class greater than
  # the current premises, cost affordable, and :relocation.requirements met. Errors:
  # {:error, :not_a_premises} / {:error, :not_an_upgrade} / {:error, :insufficient_scrip|:insufficient_cred}
  # / {:error, :requirements_unmet}; else {:ok, [{:scrip, -cost.scrip}, {:cred, -cost.cred},
  # {:set, :premises_id, target_id}]}. Note: modules and last_collected carry across relocation
  # (do NOT reset them). Unit-test the error branches and the happy path.

  # TODO: [Territory] available_modules/1 and available_relocations/1 — for the Hideout catalog.
  # available_modules: module defs not already owned, partitioned for the UI into buyable
  # (class + cost + requirements all met) vs locked (class ceiling not yet met -> "relocate"
  # hint). available_relocations: premises-flagged locations with class greater than current and
  # :relocation.requirements met, each with its cost and the class it unlocks. Unit-test the
  # buyable/locked partition against a player at class 1 vs class 2.

  # TODO: [Territory] Author the content this module reads (Constitution pass on names per §9):
  #   priv/content/territory/ladder.exs — one def %{id: "ladder", tiers: [...]} listing all 10
  #     tiers ordered deepest-first; v1 wires real requirements for tiers 1-4 (Squatter default,
  #     Tenant={:has_module,"stash"}, Operator={:has_module,"latticework_bleed"},
  #     Fixture={:has_module,"drop_point"}); tiers 5-10 reference future modules so they never derive.
  #   priv/content/modules/stash.exs — :gate, premises_class_min 1, scrip cost (Tenant keystone).
  #   priv/content/modules/latticework_bleed.exs — :income, premises_class_min 2, scrip+cred cost,
  #     rate 5/hr, cap_hours 12, trace ~1 Heat/30 scrip (Operator keystone; the flagship).
  #   priv/content/modules/drop_point.exs — :gate, premises_class_min 2, scrip+cred cost (Fixture keystone).
  #   priv/content/locations/shunt9/shunt9_player_squat.exs — add premises_class: 1.
  #   priv/content/locations/shunt9/<new class-2 safehouse>.exs — premises_class: 2, a :relocation
  #     block (cost + requirements), and an exit wired into the Shunt 9 map graph so it's navigable.
end
