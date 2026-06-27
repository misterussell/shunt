defmodule Shunt.Effects do
  @moduledoc false

  alias Shunt.Heat
  alias Shunt.Npcs.Loyalty

  @initial_meta %{heat_event: nil, loyalty_signals: [], deltas: %{}}

  def apply(player, effects) do
    {acc, meta} = do_apply(effects, player, %{}, @initial_meta)
    changes = clamp_money(acc)
    {changes, %{meta | deltas: deltas(player, changes)}}
  end

  defp deltas(player, changes) do
    changes
    |> Map.take([:scrip, :cred, :heat])
    |> Map.new(fn {field, new_value} -> {field, new_value - Map.fetch!(player, field)} end)
  end

  defp do_apply([], _player, acc, meta), do: {acc, meta}

  defp do_apply([{:scrip, delta} | rest], player, acc, meta) do
    new_value = Map.get(acc, :scrip, player.scrip) + delta
    do_apply(rest, player, Map.put(acc, :scrip, new_value), meta)
  end

  defp do_apply([{:cred, delta} | rest], player, acc, meta) do
    new_value = Map.get(acc, :cred, player.cred) + delta
    do_apply(rest, player, Map.put(acc, :cred, new_value), meta)
  end

  defp do_apply([{:heat, delta} | rest], player, acc, meta) do
    current_heat = Map.get(acc, :heat, player.heat)
    {final_heat, event} = Heat.resolve(current_heat, Heat.clamp(current_heat + delta))

    rest =
      if event do
        [{:scrip, -event.scrip_loss}, {:cred, -event.cred_loss} | rest]
      else
        rest
      end

    do_apply(rest, player, Map.put(acc, :heat, final_heat), %{meta | heat_event: event})
  end

  defp do_apply([{:inventory, key, delta} | rest], player, acc, meta) do
    current_inventory = Map.get(acc, :inventory, player.inventory)
    new_count = max(Map.get(current_inventory, key, 0) + delta, 0)
    new_inventory = Map.put(current_inventory, key, new_count)
    do_apply(rest, player, Map.put(acc, :inventory, new_inventory), meta)
  end

  defp do_apply([{:npc_loyalty, npc_key, delta} | rest], player, acc, meta) do
    was_met = Loyalty.met?(player, npc_key)
    old_value = Loyalty.value(player, npc_key)
    old_band = Loyalty.band_for(old_value)
    new_value = Loyalty.clamp(old_value + delta)
    new_band = Loyalty.band_for(new_value)

    current_npc_loyalty = Map.get(acc, :npc_loyalty, player.npc_loyalty)
    acc = Map.put(acc, :npc_loyalty, Map.put(current_npc_loyalty, npc_key, new_value))

    signals =
      meta.loyalty_signals
      |> maybe_append(not was_met, {:npc_met, npc_key})
      |> maybe_append(old_band != new_band, {:loyalty_band_changed, npc_key, old_band, new_band})

    do_apply(rest, player, acc, %{meta | loyalty_signals: signals})
  end

  defp do_apply([{:npc_progression, npc_key, delta} | rest], player, acc, meta) do
    current_progression = Map.get(acc, :npc_progression, player.npc_progression)
    new_value = max(Map.get(current_progression, npc_key, 0) + delta, 0)
    new_progression = Map.put(current_progression, npc_key, new_value)
    do_apply(rest, player, Map.put(acc, :npc_progression, new_progression), meta)
  end

  # TODO: handle {:ghostwork_mastery, family, delta} — bump the per-family crack count in
  # ghostwork_state["mastery"][family], clamped at a minimum of 0 (like :npc_progression but
  # nested one level deeper). Read current state from acc first, falling back to
  # player.ghostwork_state, then put the updated map back on acc under :ghostwork_state.

  # TODO: handle {:ghostwork_node, node_id, op} — mutate ghostwork_state["nodes"][node_id],
  # defaulting a missing node to %{"banked_layer" => -1, "hardened" => false}. Ops:
  #   {:bank_layer, n} -> put "banked_layer" => n
  #   :harden          -> put "hardened" => true
  #   :clear_hardened  -> put "hardened" => false
  # Same acc-or-player read pattern as above; put the updated state back on acc.

  defp do_apply([{:set, field, value} | rest], player, acc, meta) do
    do_apply(rest, player, Map.put(acc, field, value), meta)
  end

  defp do_apply([{:discover_location, location_key} | rest], player, acc, meta) do
    current_discovered = Map.get(acc, :discovered_locations, player.discovered_locations)

    new_discovered =
      if location_key in current_discovered do
        current_discovered
      else
        current_discovered ++ [location_key]
      end

    do_apply(rest, player, Map.put(acc, :discovered_locations, new_discovered), meta)
  end

  defp do_apply([{:modify_rep, npc, dim, delta} | rest], player, acc, meta) do
    current_reputation = Map.get(acc, :reputation, player.reputation)
    npc_rep = Map.get(current_reputation, npc, %{})
    new_value = max(Map.get(npc_rep, dim, 0) + delta, 0)
    new_reputation = Map.put(current_reputation, npc, Map.put(npc_rep, dim, new_value))
    do_apply(rest, player, Map.put(acc, :reputation, new_reputation), meta)
  end

  defp do_apply([{:knowledge, key} | rest], player, acc, meta) do
    current_knowledge = Map.get(acc, :knowledge, player.knowledge)

    new_knowledge =
      if key in current_knowledge, do: current_knowledge, else: current_knowledge ++ [key]

    do_apply(rest, player, Map.put(acc, :knowledge, new_knowledge), meta)
  end

  defp do_apply([{:contact, key} | rest], player, acc, meta) do
    current_contacts = Map.get(acc, :contacts, player.contacts)

    new_contacts =
      if key in current_contacts, do: current_contacts, else: current_contacts ++ [key]

    do_apply(rest, player, Map.put(acc, :contacts, new_contacts), meta)
  end

  defp maybe_append(list, true, item), do: list ++ [item]
  defp maybe_append(list, false, _item), do: list

  defp clamp_money(acc) do
    acc
    |> clamp_field(:scrip)
    |> clamp_field(:cred)
  end

  defp clamp_field(acc, field) do
    case Map.fetch(acc, field) do
      {:ok, value} -> Map.put(acc, field, max(value, 0))
      :error -> acc
    end
  end
end
