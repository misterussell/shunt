defmodule Shunt.Npcs do
  @moduledoc false
  alias Shunt.Content
  alias Shunt.Npcs.Loyalty
  alias Shunt.Players.Player

  @flesh_tithe_input_raw_key "cracked_bone_plate"
  @flesh_tithe_gain_scrip 15
  @flesh_tithe_heat_cost 5
  @flesh_tithe_npc_key "mother_graft"
  @loyalty_gain 5

  def list do
    Enum.sort_by(Content.all(:npcs), & &1.name)
  end

  def get!(key) do
    Content.fetch!(:npcs, key)
  end

  def can_flesh_tithe?(%Player{} = player) do
    Map.get(player.inventory, @flesh_tithe_input_raw_key, 0) >= 1
  end

  def flesh_tithe(%Player{} = player) do
    cond do
      not Loyalty.roll_reliable?(player, @flesh_tithe_npc_key) ->
        {:error, :npc_unreliable}

      not can_flesh_tithe?(player) ->
        {:error, :insufficient_materials}

      true ->
        gain =
          floor(@flesh_tithe_gain_scrip * Loyalty.price_multiplier(player, @flesh_tithe_npc_key))

        {:ok,
         [
           {:inventory, @flesh_tithe_input_raw_key, -1},
           {:heat, @flesh_tithe_heat_cost},
           {:scrip, gain},
           {:npc_loyalty, @flesh_tithe_npc_key, @loyalty_gain}
         ]}
    end
  end

  @move_goods_npc_key "rook"

  def can_move_goods?(%Player{held_item_key: nil}), do: false
  def can_move_goods?(%Player{}), do: true

  def move_goods(%Player{held_item_key: nil}), do: {:error, :no_held_item}

  def move_goods(%Player{held_item_key: key} = player) do
    if Loyalty.roll_reliable?(player, @move_goods_npc_key) do
      item = Shunt.Fencing.Catalog.fetch!(key)

      payout =
        floor(item.sell_value * 0.5 * Loyalty.price_multiplier(player, @move_goods_npc_key))

      {:ok,
       [
         {:scrip, payout},
         {:set, :held_item_key, nil},
         {:npc_loyalty, @move_goods_npc_key, @loyalty_gain}
       ]}
    else
      {:error, :npc_unreliable}
    end
  end

  @look_the_other_way_cost_scrip 20
  @look_the_other_way_heat_reduction 15
  @look_the_other_way_npc_key "nine_iron"

  defp look_the_other_way_cost(player) do
    ceil(
      @look_the_other_way_cost_scrip *
        Loyalty.cost_multiplier(player, @look_the_other_way_npc_key)
    )
  end

  def can_look_the_other_way?(%Player{} = player) do
    player.scrip >= look_the_other_way_cost(player)
  end

  def look_the_other_way(%Player{} = player) do
    cost = look_the_other_way_cost(player)

    cond do
      player.scrip < cost ->
        {:error, :insufficient_scrip}

      not Loyalty.roll_reliable?(player, @look_the_other_way_npc_key) ->
        {:error, :npc_unreliable}

      true ->
        {:ok,
         [
           {:scrip, -cost},
           {:heat, -@look_the_other_way_heat_reduction},
           {:npc_loyalty, @look_the_other_way_npc_key, @loyalty_gain}
         ]}
    end
  end

  @data_drop_cost_scrip 20
  @data_drop_gain_cred 1
  @data_drop_npc_key "splice"

  defp data_drop_cost(player) do
    ceil(@data_drop_cost_scrip * Loyalty.cost_multiplier(player, @data_drop_npc_key))
  end

  def can_data_drop?(%Player{} = player), do: player.scrip >= data_drop_cost(player)

  def data_drop(%Player{} = player) do
    cost = data_drop_cost(player)
    gain = floor(@data_drop_gain_cred * Loyalty.price_multiplier(player, @data_drop_npc_key))

    cond do
      player.scrip < cost ->
        {:error, :insufficient_scrip}

      not Loyalty.roll_reliable?(player, @data_drop_npc_key) ->
        {:error, :npc_unreliable}

      true ->
        {:ok, [{:scrip, -cost}, {:cred, gain}, {:npc_loyalty, @data_drop_npc_key, @loyalty_gain}]}
    end
  end

  @settle_the_books_cost_cred 1
  @settle_the_books_gain_scrip 10
  @settle_the_books_npc_key "tally"

  defp settle_the_books_cost(player) do
    ceil(@settle_the_books_cost_cred * Loyalty.cost_multiplier(player, @settle_the_books_npc_key))
  end

  def can_settle_the_books?(%Player{} = player), do: player.cred >= settle_the_books_cost(player)

  def settle_the_books(%Player{} = player) do
    cost = settle_the_books_cost(player)

    gain =
      floor(
        @settle_the_books_gain_scrip * Loyalty.price_multiplier(player, @settle_the_books_npc_key)
      )

    cond do
      player.cred < cost ->
        {:error, :insufficient_cred}

      not Loyalty.roll_reliable?(player, @settle_the_books_npc_key) ->
        {:error, :npc_unreliable}

      true ->
        {:ok,
         [
           {:cred, -cost},
           {:scrip, gain},
           {:npc_loyalty, @settle_the_books_npc_key, @loyalty_gain}
         ]}
    end
  end
end
