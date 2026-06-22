defmodule Shunt.NpcsTest do
  # TODO: Switch to `use Shunt.DataCase` (instead of ExUnit.Case) once flesh_tithe/1,
  # move_goods/1, look_the_other_way/1, data_drop/1, settle_the_books/1 are implemented,
  # since they hit Repo — mirror the alias list and setup style in test/shunt/fencing_test.exs
  # (alias Shunt.Players, alias Shunt.Repo, plus Shunt.Fencing.Catalog for move_goods/1 tests).
  use ExUnit.Case, async: true

  alias Shunt.Npcs

  describe "list/0" do
    test "returns 5 npcs sorted by name" do
      names = Enum.map(Npcs.list(), & &1.name)

      assert length(names) == 5
      assert names == Enum.sort(names)
    end
  end

  describe "get!/1" do
    test "returns the npc for a known key" do
      assert Npcs.get!("tally").name == "Tally"
    end

    test "raises for an unknown key" do
      assert_raise RuntimeError, fn -> Npcs.get!("unknown") end
    end
  end

  # TODO: describe "flesh_tithe/1" do
  #   test "consumes 1 cracked_bone_plate and grants 15 scrip, raising heat by 5 (via Heat.resolve)":
  #     create player with inventory: %{"cracked_bone_plate" => 1}, scrip: 0, heat: 0
  #     assert {:ok, updated, _event} = Npcs.flesh_tithe(player)
  #     assert updated.inventory["cracked_bone_plate"] == 0
  #     assert updated.scrip == 15
  #     assert updated.heat == 5
  #   test "returns {:error, :insufficient_materials} when player holds none":
  #     player with inventory: %{} -> assert Npcs.flesh_tithe(player) == {:error, :insufficient_materials}

  # TODO: describe "move_goods/1" do
  #   test "pays 50% of the held item's sell_value in scrip and clears held_item_key":
  #     item = Shunt.Fencing.Catalog.fetch!("scrap_dermal_plating")
  #     player with held_item_key: item.key, scrip: 0
  #     assert {:ok, updated} = Npcs.move_goods(player)
  #     assert updated.scrip == floor(item.sell_value * 0.5)
  #     assert updated.held_item_key == nil
  #   test "returns {:error, :no_held_item} when held_item_key is nil"

  # TODO: describe "look_the_other_way/1" do
  #   test "costs 20 scrip and reduces heat by 15 (clamped at 0)":
  #     player with scrip: 20, heat: 10 -> assert {:ok, updated} = Npcs.look_the_other_way(player)
  #     assert updated.scrip == 0
  #     assert updated.heat == 0
  #   test "returns {:error, :insufficient_scrip} when scrip < 20"

  # TODO: describe "data_drop/1" do
  #   test "costs 20 scrip and grants 1 cred":
  #     player with scrip: 20, cred: 0 -> assert {:ok, updated} = Npcs.data_drop(player)
  #     assert updated.scrip == 0
  #     assert updated.cred == 1
  #   test "returns {:error, :insufficient_scrip} when scrip < 20"

  # TODO: describe "settle_the_books/1" do
  #   test "costs 1 cred and grants 10 scrip":
  #     player with cred: 1, scrip: 0 -> assert {:ok, updated} = Npcs.settle_the_books(player)
  #     assert updated.cred == 0
  #     assert updated.scrip == 10
  #   test "returns {:error, :insufficient_cred} when cred < 1"
end
