defmodule Shunt.Contacts do
  @moduledoc """
  Hub-facing "comms network" layer for contact NPCs.

  A contact is a `%Shunt.World.NPC{}` with a non-empty `services:` list (see
  lib/shunt/world/npc.ex). Contacts are met and built up in the world via their `story_arcs`
  (the ordinary world-NPC event machinery); their *deals* are invoked remotely from the Hub
  through this module. Loyalty/trust is unchanged and keyed by the NPC's `contact_key`
  (see `Shunt.Npcs.Loyalty`).

  A service is authored as `%{key, name, description, requirements, params}`. Tiered variants of
  one deal share a `key` (same resolver) with deeper `requirements` and better `params`; each
  tier's flag is granted by an arc-milestone event. The Hub shows ONE button per deal `key` at
  the best-unlocked tier — the highest tier whose `requirements` are met — so a deepening
  relationship silently upgrades the same deal (higher tiers strictly dominate). Locked tiers are
  never shown.
  """
  alias Shunt.Content
  alias Shunt.Fencing.Catalog
  alias Shunt.Npcs.Loyalty
  alias Shunt.Players.Player
  alias Shunt.Requirements

  @loyalty_gain 5

  @doc """
  Known contacts for the Hub: every world NPC with >= 1 currently-unlocked service, each carrying
  its loyalty value and only its unlocked services (one per deal key, at the best-unlocked tier).
  Sorted by name.
  """
  def list_for_player(%Player{} = player) do
    Content.all(:world_npcs)
    |> Enum.filter(&(&1.services != []))
    |> Enum.map(fn npc ->
      %{
        npc: npc,
        loyalty: Loyalty.value(player, npc.contact_key),
        services: unlocked(player, npc)
      }
    end)
    |> Enum.reject(&(&1.services == []))
    |> Enum.sort_by(& &1.npc.name)
  end

  @doc """
  Run a contact's deal from the Hub. `service_key` is the deal key as a string (the value the Hub
  posts back). Resolves the best-unlocked tier for that deal, then applies the deal's math,
  loyalty multipliers, and reliability roll. Returns `{:ok, effects}` | `{:error, reason}`
  (`:service_locked` when no tier is unlocked, plus the deal's own resource/reliability errors).
  """
  def resolve_service(%Player{} = player, contact_key, service_key) do
    with {:ok, npc} <- fetch_contact(contact_key),
         {:ok, service} <- best_unlocked(player, npc, service_key) do
      run(service.key, player, contact_key, service.params)
    end
  end

  @doc """
  Whether the player can currently pay for the best-unlocked tier of a deal — for Hub button
  styling only (never runs the deal). False for a locked or unknown deal.
  """
  def can_afford?(%Player{} = player, contact_key, service_key) do
    with {:ok, npc} <- fetch_contact(contact_key),
         {:ok, service} <- best_unlocked(player, npc, service_key) do
      affordable?(service.key, player, contact_key, service.params)
    else
      _ -> false
    end
  end

  @doc "Display name for a contact_key (used by the Hub loyalty-signal flashes); the key itself if unknown."
  def name(contact_key) do
    case fetch_contact(contact_key) do
      {:ok, npc} -> npc.name
      _ -> contact_key
    end
  end

  defp fetch_contact(contact_key) do
    case Enum.find(Content.all(:world_npcs), &(&1.contact_key == contact_key)) do
      nil -> {:error, :unknown_contact}
      npc -> {:ok, npc}
    end
  end

  # Unlocked deals for a contact: keep services whose requirements are met, then for each distinct
  # deal key (in first-appearance order) take the best unlocked tier.
  #
  # INVARIANT: tiers of one deal key MUST be authored in ascending order (basic -> best) in the
  # content file, so the last met tier is the best unlocked one. `List.last` picks it. (This is
  # deliberately more robust than Requirements.deepest_met_tier/2's take_while, which would stop at
  # a gap if unlock flags were granted non-cumulatively.)
  defp unlocked(player, npc) do
    met = Enum.filter(npc.services, &Requirements.met?(player, &1.requirements))

    met
    |> Enum.map(& &1.key)
    |> Enum.uniq()
    |> Enum.map(fn key -> met |> Enum.filter(&(&1.key == key)) |> List.last() end)
  end

  defp best_unlocked(player, npc, service_key) do
    case Enum.find(unlocked(player, npc), &(to_string(&1.key) == service_key)) do
      nil -> {:error, :service_locked}
      service -> {:ok, service}
    end
  end

  # --- Deal resolvers (ported from the retired Shunt.Npcs; param-driven, loyalty keyed by ck) ---

  defp run(:flesh_tithe, player, ck, %{input_key: input_key, gain_scrip: gain_scrip, heat: heat}) do
    cond do
      not Loyalty.roll_reliable?(player, ck) ->
        {:error, :npc_unreliable}

      Map.get(player.inventory, input_key, 0) < 1 ->
        {:error, :insufficient_materials}

      true ->
        gain = floor(gain_scrip * Loyalty.price_multiplier(player, ck))

        {:ok,
         [
           {:inventory, input_key, -1},
           {:heat, heat},
           {:scrip, gain},
           {:npc_loyalty, ck, @loyalty_gain}
         ]}
    end
  end

  defp run(:move_goods, %Player{held_item_key: nil}, _ck, _params), do: {:error, :no_held_item}

  defp run(:move_goods, %Player{held_item_key: key} = player, ck, %{sell_fraction: fraction}) do
    if Loyalty.roll_reliable?(player, ck) do
      item = Catalog.fetch!(key)
      payout = floor(item.sell_value * fraction * Loyalty.price_multiplier(player, ck))

      {:ok, [{:scrip, payout}, {:set, :held_item_key, nil}, {:npc_loyalty, ck, @loyalty_gain}]}
    else
      {:error, :npc_unreliable}
    end
  end

  defp run(:look_the_other_way, player, ck, %{cost: base_cost, heat_reduction: heat_reduction}) do
    cost = ceil(base_cost * Loyalty.cost_multiplier(player, ck))

    cond do
      player.scrip < cost ->
        {:error, :insufficient_scrip}

      not Loyalty.roll_reliable?(player, ck) ->
        {:error, :npc_unreliable}

      true ->
        {:ok, [{:scrip, -cost}, {:heat, -heat_reduction}, {:npc_loyalty, ck, @loyalty_gain}]}
    end
  end

  defp run(:data_drop, player, ck, %{cost: base_cost, gain_cred: gain_cred}) do
    cost = ceil(base_cost * Loyalty.cost_multiplier(player, ck))
    gain = floor(gain_cred * Loyalty.price_multiplier(player, ck))

    cond do
      player.scrip < cost -> {:error, :insufficient_scrip}
      not Loyalty.roll_reliable?(player, ck) -> {:error, :npc_unreliable}
      true -> {:ok, [{:scrip, -cost}, {:cred, gain}, {:npc_loyalty, ck, @loyalty_gain}]}
    end
  end

  defp run(:settle_the_books, player, ck, %{cost_cred: base_cost, gain_scrip: gain_scrip}) do
    cost = ceil(base_cost * Loyalty.cost_multiplier(player, ck))
    gain = floor(gain_scrip * Loyalty.price_multiplier(player, ck))

    cond do
      player.cred < cost -> {:error, :insufficient_cred}
      not Loyalty.roll_reliable?(player, ck) -> {:error, :npc_unreliable}
      true -> {:ok, [{:cred, -cost}, {:scrip, gain}, {:npc_loyalty, ck, @loyalty_gain}]}
    end
  end

  # --- Affordability mirrors of each deal (button styling only) ---

  defp affordable?(:flesh_tithe, player, _ck, %{input_key: input_key}),
    do: Map.get(player.inventory, input_key, 0) >= 1

  defp affordable?(:move_goods, player, _ck, _params), do: player.held_item_key != nil

  defp affordable?(:look_the_other_way, player, ck, %{cost: base_cost}),
    do: player.scrip >= ceil(base_cost * Loyalty.cost_multiplier(player, ck))

  defp affordable?(:data_drop, player, ck, %{cost: base_cost}),
    do: player.scrip >= ceil(base_cost * Loyalty.cost_multiplier(player, ck))

  defp affordable?(:settle_the_books, player, ck, %{cost_cred: base_cost}),
    do: player.cred >= ceil(base_cost * Loyalty.cost_multiplier(player, ck))

  # TODO (docs): document the world-NPC `contact_key` field and the `services` list shape
  # (key/name/description/requirements/params), the best-unlocked-tier rule, and the unlock-flag
  # convention in docs/SHUNT_DISTRICT_AUTHORING.md, alongside story_arcs/conditional_events.
end
