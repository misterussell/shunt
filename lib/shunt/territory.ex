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

  @doc "Reservoir fill as a 0–100 percentage of its cap (0 when the cap is 0)."
  def reservoir_pct(_reservoir, 0), do: 0
  def reservoir_pct(reservoir, cap), do: round(reservoir / cap * 100)

  @doc """
  Scrip currently pooled in the income reservoir at `now`, computed on demand from
  `player.last_collected` (offline-earnings; no scheduler). Each income module accrues
  `rate * min(elapsed_hours, cap_hours)` and they sum; a nil `last_collected` or negative
  elapsed (clock skew) yields 0.
  """
  def reservoir(%Player{} = player, now) do
    player |> reservoirs(now) |> Enum.map(& &1.amount) |> Enum.sum()
  end

  @doc """
  A single-pass snapshot of the income bleed for the Hideout page and `collect/2`: the `rate`,
  pooled `reservoir`, `cap`, and the `heat` a collect at `now` would cost — walking the player's
  income modules once, instead of each value re-deriving them. Zeros for a player with no income.
  """
  def bleed(%Player{} = player, now) do
    reservoirs = reservoirs(player, now)

    %{
      rate: reservoirs |> Enum.map(& &1.rate) |> Enum.sum(),
      cap: reservoirs |> Enum.map(& &1.cap) |> Enum.sum(),
      reservoir: reservoirs |> Enum.map(& &1.amount) |> Enum.sum(),
      heat: reservoirs |> Enum.map(&div(&1.amount, &1.trace_per)) |> Enum.sum()
    }
  end

  # Per income module: the scrip it has pooled at `now`, its trace_per (scrip per 1 Heat on
  # collect), and its rate/cap. Per-module capping; for v1's single bleed module this equals the §4
  # global formula.
  defp reservoirs(%Player{} = player, now) do
    elapsed = elapsed_hours(player.last_collected, now)

    for e <- income_effects(player) do
      cap = e.rate * e.cap_hours
      %{amount: min(trunc(e.rate * elapsed), cap), trace_per: e.trace_per, rate: e.rate, cap: cap}
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
    bleed = bleed(player, now)

    case bleed.reservoir do
      0 ->
        {:error, :nothing_to_collect}

      take ->
        {:ok, [{:scrip, take}, {:heat, bleed.heat}, {:set, :last_collected, now}]}
    end
  end

  @doc """
  The Heat a collect at `now` would cost — for the Hideout page to show the cost before the player
  commits — computed without collecting. Scales per each income module's `trace_per`.
  """
  def projected_heat(%Player{} = player, now) do
    player |> reservoirs(now) |> Enum.map(&div(&1.amount, &1.trace_per)) |> Enum.sum()
  end

  @doc """
  Buy and install a hideout module (a pure resolver). Validates, in order, that the module exists,
  isn't already owned, the premises class meets its `premises_class_min`, its extra `requirements`
  are met, and the player can afford its `cost`. On success returns the spend + install effects;
  installing an income module with no `last_collected` yet also starts accrual (`now` is passed in).
  """
  def install_module(%Player{} = player, module_key, now) do
    with {:ok, module} <- fetch_module(module_key),
         :ok <- ensure_not_owned(player, module_key),
         :ok <- ensure_premises_class(player, module),
         :ok <- ensure_requirements_met(player, module.requirements),
         :ok <- ensure_affordable(player, module.cost) do
      {:ok,
       spend(module.cost) ++ [{:install_module, module_key}] ++ income_start(player, module, now)}
    end
  end

  @doc """
  Relocate to a better premises (a pure resolver). The target must be a premises location
  (carries `:premises_class`) of a higher class than the current one, with its `:relocation`
  gates met and cost affordable. On success returns the spend + `{:set, :premises_id, ...}`;
  modules and `last_collected` carry across (not reset). Errors: `:not_a_premises`,
  `:not_an_upgrade`, `:requirements_unmet`, `:insufficient_scrip`/`:insufficient_cred`.
  """
  def relocate(%Player{} = player, target_id) do
    with {:ok, location} <- fetch_premises(target_id),
         :ok <- ensure_upgrade(player, location) do
      relocation = Map.get(location, :relocation, %{})
      cost = Map.get(relocation, :cost, %{})

      with :ok <- ensure_requirements_met(player, Map.get(relocation, :requirements, [])),
           :ok <- ensure_affordable(player, cost) do
        # Move the player into the new base too, so they stay inside the hideout after relocating
        # (location_id == premises_id is what the Hideout page gates on).
        {:ok, spend(cost) ++ [{:set, :premises_id, target_id}, {:set, :location_id, target_id}]}
      end
    end
  end

  defp fetch_premises(id) do
    case Content.fetch(:locations, id) do
      {:ok, %{premises_class: _} = location} -> {:ok, location}
      _ -> {:error, :not_a_premises}
    end
  end

  defp ensure_upgrade(player, location) do
    unless_error(location.premises_class <= premises_class(player), :not_an_upgrade)
  end

  defp fetch_module(key) do
    case Content.fetch(:modules, key) do
      {:ok, module} -> {:ok, module}
      :error -> {:error, :unknown_module}
    end
  end

  defp ensure_not_owned(player, key), do: unless_error(key in player.modules, :already_owned)

  defp ensure_premises_class(player, module) do
    unless_error(premises_class(player) < module.premises_class_min, :premises_class_too_low)
  end

  defp ensure_requirements_met(player, requirements) do
    unless_error(not Requirements.met?(player, requirements), :requirements_unmet)
  end

  defp income_start(%Player{last_collected: nil}, %{effect: %{kind: :income}}, now),
    do: [{:set, :last_collected, now}]

  defp income_start(_player, _module, _now), do: []

  defp ensure_affordable(player, cost) do
    cond do
      player.scrip < Map.get(cost, :scrip, 0) -> {:error, :insufficient_scrip}
      player.cred < Map.get(cost, :cred, 0) -> {:error, :insufficient_cred}
      true -> :ok
    end
  end

  # Spend effects for a cost map, omitting zero deltas so the effect list stays clean.
  defp spend(cost) do
    for field <- [:scrip, :cred], amount = Map.get(cost, field, 0), amount > 0 do
      {field, -amount}
    end
  end

  defp unless_error(true, error), do: {:error, error}
  defp unless_error(false, _error), do: :ok

  @doc """
  The hideout module catalog for the player: every not-yet-owned module, each tagged with a
  `status` (`:buyable` | `:locked_class` when the premises class is too low | `:locked` when other
  requirements are unmet) and `affordable?`. The Hideout page renders straight from this.
  """
  def available_modules(%Player{} = player) do
    :modules
    |> Content.all()
    |> Enum.reject(&(&1.id in player.modules))
    |> Enum.map(fn module ->
      %{
        module: module,
        status: module_status(player, module),
        affordable?: affordable?(player, module.cost)
      }
    end)
  end

  defp module_status(player, module) do
    cond do
      premises_class(player) < module.premises_class_min -> :locked_class
      not Requirements.met?(player, module.requirements) -> :locked
      true -> :buyable
    end
  end

  @doc """
  The relocation catalog: every premises location of a higher class than the player's current one,
  each with its `cost`, the `unlocks_class` it grants, a `status` (`:available` | `:locked` when the
  relocation requirements are unmet), and `affordable?`.
  """
  def available_relocations(%Player{} = player) do
    current = premises_class(player)

    :locations
    |> Content.all()
    |> Enum.filter(&(Map.has_key?(&1, :premises_class) and &1.premises_class > current))
    |> Enum.map(fn location ->
      relocation = Map.get(location, :relocation, %{})
      cost = Map.get(relocation, :cost, %{})

      %{
        location: location,
        cost: cost,
        unlocks_class: location.premises_class,
        status: relocation_status(player, relocation),
        affordable?: affordable?(player, cost)
      }
    end)
  end

  defp relocation_status(player, relocation) do
    if Requirements.met?(player, Map.get(relocation, :requirements, [])),
      do: :available,
      else: :locked
  end

  defp affordable?(player, cost) do
    player.scrip >= Map.get(cost, :scrip, 0) and player.cred >= Map.get(cost, :cred, 0)
  end
end
