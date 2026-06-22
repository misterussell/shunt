defmodule Shunt.NpcsTest do
  use Shunt.DataCase

  alias Shunt.Npcs
  alias Shunt.Players
  alias Shunt.Repo

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

  # TODO: once flesh_tithe/1, move_goods/1, look_the_other_way/1, data_drop/1, and
  # settle_the_books/1 are wired into NPC Loyalty (per the TODOs in lib/shunt/npcs.ex), add
  # to each describe block below:
  #   - a test that a fresh player (never met the NPC) ends up with
  #     updated.npc_loyalty["<npc_key>"] == 55 after a successful call (50 start + 5 gain)
  #   - a test that calling the action when the player's npc_loyalty for that NPC is e.g. 0
  #     can return {:error, :npc_unreliable} without changing scrip/cred/inventory/heat —
  #     since the reliability roll is probabilistic, loop the call ~200 times against a
  #     freshly-reset hostile-loyalty player and assert at least one call returns
  #     {:error, :npc_unreliable} (mirror Shunt.Npcs.Loyalty's own roll_reliable?/2 test in
  #     loyalty_test.exs for this style)
  #   - a test that a favored-loyalty player (npc_loyalty for that NPC >= 75) gets the scaled
  #     (better) price: e.g. for flesh_tithe, floor(15 * 1.2) == 18 scrip instead of 15; for
  #     look_the_other_way, ceil(20 * 0.8) == 16 scrip cost instead of 20
  #   - a test that a hostile-loyalty player (npc_loyalty for that NPC <= 24) gets the scaled
  #     (worse) price: e.g. floor(15 * 0.8) == 12 scrip for flesh_tithe; ceil(20 * 1.25) == 25
  #     scrip cost for look_the_other_way
  describe "flesh_tithe/1" do
    test "consumes 1 cracked_bone_plate and grants 15 scrip, raising heat by 5" do
      player =
        Players.create_player!()
        |> Ecto.Changeset.change(inventory: %{"cracked_bone_plate" => 1}, scrip: 0, heat: 0)
        |> Repo.update!()

      assert {:ok, updated, _event} = Npcs.flesh_tithe(player)
      assert updated.inventory["cracked_bone_plate"] == 0
      assert updated.scrip == 15
      assert updated.heat == 5
    end

    test "returns {:error, :insufficient_materials} when player holds none" do
      player = Players.create_player!()

      assert Npcs.flesh_tithe(player) == {:error, :insufficient_materials}
    end
  end

  describe "move_goods/1" do
    test "pays 50% of the held item's sell_value in scrip and clears held_item_key" do
      item = Shunt.Fencing.Catalog.fetch!("scrap_dermal_plating")

      player =
        Players.create_player!()
        |> Ecto.Changeset.change(held_item_key: item.key, scrip: 0)
        |> Repo.update!()

      assert {:ok, updated} = Npcs.move_goods(player)
      assert updated.scrip == floor(item.sell_value * 0.5)
      assert updated.held_item_key == nil
    end

    test "returns {:error, :no_held_item} when held_item_key is nil" do
      player = Players.create_player!()

      assert Npcs.move_goods(player) == {:error, :no_held_item}
    end
  end

  describe "look_the_other_way/1" do
    test "costs 20 scrip and reduces heat by 15 (clamped at 0)" do
      player =
        Players.create_player!()
        |> Ecto.Changeset.change(scrip: 20, heat: 10)
        |> Repo.update!()

      assert {:ok, updated} = Npcs.look_the_other_way(player)
      assert updated.scrip == 0
      assert updated.heat == 0
    end

    test "returns {:error, :insufficient_scrip} when scrip < 20" do
      player = Players.create_player!()

      assert Npcs.look_the_other_way(player) == {:error, :insufficient_scrip}
    end
  end

  describe "data_drop/1" do
    test "costs 20 scrip and grants 1 cred" do
      player =
        Players.create_player!()
        |> Ecto.Changeset.change(scrip: 20, cred: 0)
        |> Repo.update!()

      assert {:ok, updated} = Npcs.data_drop(player)
      assert updated.scrip == 0
      assert updated.cred == 1
    end

    test "returns {:error, :insufficient_scrip} when scrip < 20" do
      player = Players.create_player!()

      assert Npcs.data_drop(player) == {:error, :insufficient_scrip}
    end
  end

  describe "settle_the_books/1" do
    test "costs 1 cred and grants 10 scrip" do
      player =
        Players.create_player!()
        |> Ecto.Changeset.change(cred: 1, scrip: 0)
        |> Repo.update!()

      assert {:ok, updated} = Npcs.settle_the_books(player)
      assert updated.cred == 0
      assert updated.scrip == 10
    end

    test "returns {:error, :insufficient_cred} when cred < 1" do
      player = Players.create_player!()

      assert Npcs.settle_the_books(player) == {:error, :insufficient_cred}
    end
  end
end
