defmodule Shunt.Npcs do
  @moduledoc false
  alias Shunt.Npcs.Store

  def list do
    Enum.sort_by(Store.all(), & &1.name)
  end

  def get!(key) do
    Store.fetch!(key)
  end

  # TODO: Implement flesh_tithe/1 (Mother Graft's "Flesh Tithe" trade action).
  # Define module attributes @flesh_tithe_input_raw_key "cracked_bone_plate",
  # @flesh_tithe_gain_scrip 15, @flesh_tithe_heat_cost 5.
  # def flesh_tithe(%Player{} = player):
  #   - if Map.get(player.inventory, @flesh_tithe_input_raw_key, 0) < 1, return {:error, :insufficient_materials}
  #   - otherwise decrement that raw material by 1 in player.inventory, resolve
  #     {final_heat, event} = Heat.resolve(player.heat, Heat.clamp(player.heat + @flesh_tithe_heat_cost)),
  #     increment scrip by @flesh_tithe_gain_scrip (no cred change), set heat: final_heat,
  #     via Ecto.Changeset.change/Repo.update (mirror lib/shunt/crafting.ex's scavenge/1 and
  #     lib/shunt/fencing.ex's event_loss/with_event helpers for the {:ok, player, event} return shape)
  #   - aliases needed: Shunt.Heat, Shunt.Repo, Shunt.Players.Player

  # TODO: Implement move_goods/1 (Rook's "Move Goods" trade action).
  # def move_goods(%Player{held_item_key: nil}), do: {:error, :no_held_item}
  # def move_goods(%Player{held_item_key: key} = player):
  #   - item = Shunt.Fencing.Catalog.fetch!(key)
  #   - payout = floor(item.sell_value * 0.5)
  #   - increment player.scrip by payout, set held_item_key: nil, no heat/cred change
  #   - via Ecto.Changeset.change/Repo.update, return {:ok, player} (no heat event, unlike Fencing.sell_held_item/1)
  #   - alias needed: Shunt.Fencing.Catalog

  # TODO: Implement look_the_other_way/1 (Nine-Iron's "Look the Other Way" trade action).
  # Define @look_the_other_way_cost_scrip 20, @look_the_other_way_heat_reduction 15.
  # def look_the_other_way(%Player{scrip: scrip}) when scrip < @look_the_other_way_cost_scrip,
  #   do: {:error, :insufficient_scrip}
  # def look_the_other_way(%Player{} = player):
  #   - decrement scrip by @look_the_other_way_cost_scrip, set heat: Heat.clamp(player.heat - @look_the_other_way_heat_reduction)
  #   - via Ecto.Changeset.change/Repo.update, return {:ok, player} (Heat.clamp only, no Heat.resolve,
  #     since heat is decreasing — mirror lib/shunt/players.ex's lay_low/1 exactly, just priced in scrip instead of cred)

  # TODO: Implement data_drop/1 (Splice's "Data Drop" trade action).
  # Define @data_drop_cost_scrip 20, @data_drop_gain_cred 1.
  # def data_drop(%Player{scrip: scrip}) when scrip < @data_drop_cost_scrip, do: {:error, :insufficient_scrip}
  # def data_drop(%Player{} = player):
  #   - decrement scrip by @data_drop_cost_scrip, increment cred by @data_drop_gain_cred
  #   - via Ecto.Changeset.change/Repo.update, return {:ok, player}

  # TODO: Implement settle_the_books/1 (Tally's "Settle the Books" trade action).
  # Define @settle_the_books_cost_cred 1, @settle_the_books_gain_scrip 10.
  # def settle_the_books(%Player{cred: cred}) when cred < @settle_the_books_cost_cred,
  #   do: {:error, :insufficient_cred}
  # def settle_the_books(%Player{} = player):
  #   - decrement cred by @settle_the_books_cost_cred, increment scrip by @settle_the_books_gain_scrip
  #   - via Ecto.Changeset.change/Repo.update, return {:ok, player}
end
