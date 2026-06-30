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

  alias Shunt.Content
  alias Shunt.Players.Player
  alias Shunt.Requirements

  @default_premises_class 1
  @default_tier {1, "Squatter"}

  @doc """
  The player's derived Territory tier as `{n, name}` — the deepest ladder rung whose keystone
  requirements are met (`Content` `:territory` "ladder", ordered deepest-first), else the default
  `#{inspect(@default_tier)}`. Derived from `player.modules`; never stored (mirrors Shunt.District).
  """
  def tier(%Player{} = player) do
    Content.fetch!(:territory, "ladder").tiers
    |> Enum.find_value(@default_tier, fn rung ->
      if Requirements.met?(player, rung.requirements), do: {rung.tier, rung.name}
    end)
  end

  @doc "The player's premises location content, or `:error` if its id is unknown."
  def premises(%Player{premises_id: id}), do: Content.fetch(:locations, id)

  @doc """
  The class of the player's current premises, read from the location's `:premises_class`.
  Defaults to class #{@default_premises_class} for a non-premises location or an unknown
  premises id (degrades rather than crashing, like the other derived reads).
  """
  def premises_class(%Player{} = player) do
    case premises(player) do
      {:ok, location} -> Map.get(location, :premises_class, @default_premises_class)
      :error -> @default_premises_class
    end
  end

  @doc "Total scrip/hour the player's installed income modules produce."
  def income_rate(%Player{} = player) do
    player |> income_effects() |> Enum.map(& &1.rate) |> Enum.sum()
  end

  @doc "The combined income reservoir cap (the most scrip that can pool before collection)."
  def reservoir_cap(%Player{} = player) do
    player |> income_effects() |> Enum.map(&(&1.rate * &1.cap_hours)) |> Enum.sum()
  end

  @doc """
  Scrip currently pooled in the income reservoir at `now`, computed on demand from
  `player.last_collected` (offline-earnings; no scheduler). Each income module accrues
  `rate * min(elapsed_hours, cap_hours)` and they sum; a nil `last_collected` or negative
  elapsed (clock skew) yields 0.
  """
  def reservoir(%Player{} = player, now) do
    player |> reservoirs(now) |> Enum.map(& &1.amount) |> Enum.sum()
  end

  # Per income module: the scrip it has pooled at `now` and its trace_per (scrip per 1 Heat on
  # collect). Per-module capping; for v1's single bleed module this equals the §4 global formula.
  defp reservoirs(%Player{} = player, now) do
    elapsed = elapsed_hours(player.last_collected, now)

    for e <- income_effects(player) do
      %{amount: min(trunc(e.rate * elapsed), e.rate * e.cap_hours), trace_per: e.trace_per}
    end
  end

  # The :income effect maps of the player's installed modules (gate/unauthored modules contribute none).
  defp income_effects(%Player{modules: modules}) do
    modules
    |> Enum.map(&Content.fetch(:modules, &1))
    |> Enum.flat_map(fn
      {:ok, %{effect: %{kind: :income} = effect}} -> [effect]
      _ -> []
    end)
  end

  defp elapsed_hours(nil, _now), do: 0.0
  defp elapsed_hours(last_collected, now), do: max(0, DateTime.diff(now, last_collected)) / 3600

  @doc """
  Collect the income reservoir at `now` (a pure resolver dispatched via `Players.dispatch`).
  Banks the pooled scrip, charges trace Heat scaled to the take (per each income module's
  `trace_per`), and resets `last_collected`. Returns `{:error, :nothing_to_collect}` when the
  reservoir is empty. The `{:heat, ...}` effect routes through `Effects.apply -> Heat.resolve`,
  so a greedy collect that crosses a band can trip a Heat event.
  """
  def collect(%Player{} = player, now) do
    sources = reservoirs(player, now)
    take = sources |> Enum.map(& &1.amount) |> Enum.sum()

    if take == 0 do
      {:error, :nothing_to_collect}
    else
      heat = sources |> Enum.map(&div(&1.amount, &1.trace_per)) |> Enum.sum()
      {:ok, [{:scrip, take}, {:heat, heat}, {:set, :last_collected, now}]}
    end
  end

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

  # TODO: [Territory] Author the remaining content (Constitution pass on names per §9). Done in the
  # foundation slice: priv/content/territory/ladder.exs and premises_class: 1 on the squat. Still to
  # author, alongside the resolvers/catalog that read them:
  #   priv/content/modules/stash.exs — :gate, premises_class_min 1, scrip cost (Tenant keystone).
  #   priv/content/modules/drop_point.exs — :gate, premises_class_min 2, scrip+cred cost (Fixture keystone).
  #   (latticework_bleed.exs is authored — the income slice.)
  #   priv/content/locations/shunt9/<new class-2 safehouse>.exs — premises_class: 2, a :relocation
  #     block (cost + requirements), and an exit wired into the Shunt 9 map graph so it's navigable.
end
