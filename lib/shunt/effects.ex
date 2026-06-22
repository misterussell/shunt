defmodule Shunt.Effects do
  @moduledoc false

  alias Shunt.Heat
  alias Shunt.Npcs.Loyalty

  @initial_meta %{heat_event: nil, loyalty_signals: []}

  def apply(player, effects) do
    {acc, meta} = do_apply(effects, player, %{}, @initial_meta)
    {clamp_money(acc), meta}
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

  defp do_apply([{:set, field, value} | rest], player, acc, meta) do
    do_apply(rest, player, Map.put(acc, field, value), meta)
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
