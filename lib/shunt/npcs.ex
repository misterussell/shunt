defmodule Shunt.Npcs do
  @moduledoc false
  alias Shunt.Heat
  alias Shunt.Npcs.Store
  alias Shunt.Players.Player
  alias Shunt.Repo

  @flesh_tithe_input_raw_key "cracked_bone_plate"
  @flesh_tithe_gain_scrip 15
  @flesh_tithe_heat_cost 5

  def list do
    Enum.sort_by(Store.all(), & &1.name)
  end

  def get!(key) do
    Store.fetch!(key)
  end

  def flesh_tithe(%Player{} = player) do
    if Map.get(player.inventory, @flesh_tithe_input_raw_key, 0) < 1 do
      {:error, :insufficient_materials}
    else
      {final_heat, event} =
        Heat.resolve(player.heat, Heat.clamp(player.heat + @flesh_tithe_heat_cost))

      player
      |> Ecto.Changeset.change(%{
        inventory: Map.update!(player.inventory, @flesh_tithe_input_raw_key, &(&1 - 1)),
        scrip: player.scrip + @flesh_tithe_gain_scrip,
        heat: final_heat
      })
      |> Repo.update()
      |> with_event(event)
    end
  end

  defp with_event({:ok, player}, event), do: {:ok, player, event}
  defp with_event({:error, reason}, _event), do: {:error, reason}

  def move_goods(%Player{held_item_key: nil}), do: {:error, :no_held_item}

  def move_goods(%Player{held_item_key: key} = player) do
    item = Shunt.Fencing.Catalog.fetch!(key)
    payout = floor(item.sell_value * 0.5)

    player
    |> Ecto.Changeset.change(%{scrip: player.scrip + payout, held_item_key: nil})
    |> Repo.update()
  end

  @look_the_other_way_cost_scrip 20
  @look_the_other_way_heat_reduction 15

  def look_the_other_way(%Player{scrip: scrip}) when scrip < @look_the_other_way_cost_scrip,
    do: {:error, :insufficient_scrip}

  def look_the_other_way(%Player{} = player) do
    player
    |> Ecto.Changeset.change(%{
      scrip: player.scrip - @look_the_other_way_cost_scrip,
      heat: Heat.clamp(player.heat - @look_the_other_way_heat_reduction)
    })
    |> Repo.update()
  end

  @data_drop_cost_scrip 20
  @data_drop_gain_cred 1

  def data_drop(%Player{scrip: scrip}) when scrip < @data_drop_cost_scrip,
    do: {:error, :insufficient_scrip}

  def data_drop(%Player{} = player) do
    player
    |> Ecto.Changeset.change(%{
      scrip: player.scrip - @data_drop_cost_scrip,
      cred: player.cred + @data_drop_gain_cred
    })
    |> Repo.update()
  end

  @settle_the_books_cost_cred 1
  @settle_the_books_gain_scrip 10

  def settle_the_books(%Player{cred: cred}) when cred < @settle_the_books_cost_cred,
    do: {:error, :insufficient_cred}

  def settle_the_books(%Player{} = player) do
    player
    |> Ecto.Changeset.change(%{
      cred: player.cred - @settle_the_books_cost_cred,
      scrip: player.scrip + @settle_the_books_gain_scrip
    })
    |> Repo.update()
  end
end
