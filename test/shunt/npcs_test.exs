defmodule Shunt.NpcsTest do
  use Shunt.DataCase

  alias Shunt.Npcs
  alias Shunt.Players
  alias Shunt.Repo

  # TODO: per priv/docs/architecture.md Section 3 & 6, once flesh_tithe/1, move_goods/1,
  # look_the_other_way/1, data_drop/1, and settle_the_books/1 in lib/shunt/npcs.ex return
  # effect lists instead of {:ok, %Player{}, meta} / {:ok, %Player{}} / {:error, reason},
  # rewrite every test below that exercises those 5 functions to build a plain
  # %Shunt.Players.Player{} struct literal (no Players.create_player!/0, no Repo, no
  # Ecto.Changeset) and assert directly on the returned {:ok, effects} list - e.g.
  # flesh_tithe/1's success test becomes an assertion that the returned effects list contains
  # {:inventory, "raw_flesh_key", -1}, {:heat, ...}, {:scrip, ...}, and
  # {:npc_loyalty, "tally", 5} (loyalty band-transition assertions move to
  # test/shunt/effects_test.exs, since Shunt.Effects now owns that computation - see the TODO
  # in lib/shunt/effects.ex). roll_reliable?/2's probabilistic loop-based tests should stay
  # where they are since that logic isn't moving. list/0 and get!/1 tests below are unaffected.
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

    test "a fresh player gains loyalty with mother_graft on a successful tithe" do
      player =
        Players.create_player!()
        |> Ecto.Changeset.change(inventory: %{"cracked_bone_plate" => 1})
        |> Repo.update!()

      assert {:ok, updated, _event} = Npcs.flesh_tithe(player)
      assert updated.npc_loyalty["mother_graft"] == 55
    end

    test "loyalty accumulates and persists across repeated tithes with the same NPC" do
      player =
        Players.create_player!()
        |> Ecto.Changeset.change(inventory: %{"cracked_bone_plate" => 2})
        |> Repo.update!()

      assert {:ok, player, _event} = Npcs.flesh_tithe(player)
      assert player.npc_loyalty["mother_graft"] == 55

      assert {:ok, player, _event} = Npcs.flesh_tithe(player)
      assert player.npc_loyalty["mother_graft"] == 60

      assert Repo.get!(Shunt.Players.Player, player.id).npc_loyalty["mother_graft"] == 60
    end

    test "a hostile-loyalty player can get {:error, :npc_unreliable} without spending materials" do
      results =
        Enum.map(1..200, fn _ ->
          player =
            Players.create_player!()
            |> Ecto.Changeset.change(
              inventory: %{"cracked_bone_plate" => 1},
              npc_loyalty: %{"mother_graft" => 0}
            )
            |> Repo.update!()

          {Npcs.flesh_tithe(player), player}
        end)

      assert Enum.any?(results, fn {result, _player} -> result == {:error, :npc_unreliable} end)

      assert Enum.all?(results, fn {result, player} ->
               case result do
                 {:error, :npc_unreliable} ->
                   player.inventory["cracked_bone_plate"] == 1

                 _ ->
                   true
               end
             end)
    end

    test "a favored-loyalty player gets a scaled (better) scrip gain" do
      player =
        Players.create_player!()
        |> Ecto.Changeset.change(
          inventory: %{"cracked_bone_plate" => 1},
          npc_loyalty: %{"mother_graft" => 80}
        )
        |> Repo.update!()

      assert {:ok, updated, _event} = Npcs.flesh_tithe(player)
      assert updated.scrip == floor(15 * 1.2)
      assert updated.scrip == 18
    end

    test "a hostile-loyalty player gets a scaled (worse) scrip gain" do
      player =
        Players.create_player!()
        |> Ecto.Changeset.change(
          inventory: %{"cracked_bone_plate" => 1},
          npc_loyalty: %{"mother_graft" => 24}
        )
        |> Repo.update!()

      result =
        Enum.reduce_while(1..200, nil, fn _, _acc ->
          case Npcs.flesh_tithe(player) do
            {:ok, updated, _event} -> {:halt, updated}
            {:error, :npc_unreliable} -> {:cont, nil}
          end
        end)

      refute is_nil(result)
      assert result.scrip == floor(15 * 0.8)
      assert result.scrip == 12
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

    test "a fresh player gains loyalty with rook on a successful sale" do
      item = Shunt.Fencing.Catalog.fetch!("scrap_dermal_plating")

      player =
        Players.create_player!()
        |> Ecto.Changeset.change(held_item_key: item.key)
        |> Repo.update!()

      assert {:ok, updated} = Npcs.move_goods(player)
      assert updated.npc_loyalty["rook"] == 55
    end

    test "a hostile-loyalty player can get {:error, :npc_unreliable} without losing the held item" do
      item = Shunt.Fencing.Catalog.fetch!("scrap_dermal_plating")

      results =
        Enum.map(1..200, fn _ ->
          player =
            Players.create_player!()
            |> Ecto.Changeset.change(held_item_key: item.key, npc_loyalty: %{"rook" => 0})
            |> Repo.update!()

          {Npcs.move_goods(player), player}
        end)

      assert Enum.any?(results, fn {result, _player} -> result == {:error, :npc_unreliable} end)

      assert Enum.all?(results, fn {result, player} ->
               case result do
                 {:error, :npc_unreliable} -> player.held_item_key == item.key
                 _ -> true
               end
             end)
    end

    test "a favored-loyalty player gets a scaled (better) payout" do
      item = Shunt.Fencing.Catalog.fetch!("scrap_dermal_plating")

      player =
        Players.create_player!()
        |> Ecto.Changeset.change(held_item_key: item.key, npc_loyalty: %{"rook" => 80})
        |> Repo.update!()

      assert {:ok, updated} = Npcs.move_goods(player)
      assert updated.scrip == floor(item.sell_value * 0.5 * 1.2)
    end

    test "a hostile-loyalty player gets a scaled (worse) payout" do
      item = Shunt.Fencing.Catalog.fetch!("scrap_dermal_plating")

      player =
        Players.create_player!()
        |> Ecto.Changeset.change(held_item_key: item.key, npc_loyalty: %{"rook" => 24})
        |> Repo.update!()

      result =
        Enum.reduce_while(1..200, nil, fn _, _acc ->
          case Npcs.move_goods(player) do
            {:ok, updated} -> {:halt, updated}
            {:error, :npc_unreliable} -> {:cont, nil}
          end
        end)

      refute is_nil(result)
      assert result.scrip == floor(item.sell_value * 0.5 * 0.8)
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

    test "a fresh player gains loyalty with nine_iron on a successful bribe" do
      player =
        Players.create_player!()
        |> Ecto.Changeset.change(scrip: 20)
        |> Repo.update!()

      assert {:ok, updated} = Npcs.look_the_other_way(player)
      assert updated.npc_loyalty["nine_iron"] == 55
    end

    test "a hostile-loyalty player can get {:error, :npc_unreliable} without spending scrip" do
      results =
        Enum.map(1..200, fn _ ->
          player =
            Players.create_player!()
            |> Ecto.Changeset.change(scrip: 25, npc_loyalty: %{"nine_iron" => 0})
            |> Repo.update!()

          {Npcs.look_the_other_way(player), player}
        end)

      assert Enum.any?(results, fn {result, _player} -> result == {:error, :npc_unreliable} end)

      assert Enum.all?(results, fn {result, player} ->
               case result do
                 {:error, :npc_unreliable} -> player.scrip == 25
                 _ -> true
               end
             end)
    end

    test "a favored-loyalty player gets a scaled (better) scrip cost" do
      player =
        Players.create_player!()
        |> Ecto.Changeset.change(scrip: 20, npc_loyalty: %{"nine_iron" => 80})
        |> Repo.update!()

      assert {:ok, updated} = Npcs.look_the_other_way(player)
      assert updated.scrip == 20 - ceil(20 * 0.8)
      assert updated.scrip == 4
    end

    test "a hostile-loyalty player gets a scaled (worse) scrip cost" do
      player =
        Players.create_player!()
        |> Ecto.Changeset.change(scrip: 25, npc_loyalty: %{"nine_iron" => 24})
        |> Repo.update!()

      result =
        Enum.reduce_while(1..200, nil, fn _, _acc ->
          case Npcs.look_the_other_way(player) do
            {:ok, updated} -> {:halt, updated}
            {:error, :npc_unreliable} -> {:cont, nil}
          end
        end)

      refute is_nil(result)
      assert result.scrip == 25 - ceil(20 * 1.25)
      assert result.scrip == 0
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

    test "a fresh player gains loyalty with splice on a successful data drop" do
      player =
        Players.create_player!()
        |> Ecto.Changeset.change(scrip: 20)
        |> Repo.update!()

      assert {:ok, updated} = Npcs.data_drop(player)
      assert updated.npc_loyalty["splice"] == 55
    end

    test "a hostile-loyalty player can get {:error, :npc_unreliable} without spending scrip" do
      results =
        Enum.map(1..200, fn _ ->
          player =
            Players.create_player!()
            |> Ecto.Changeset.change(scrip: 25, npc_loyalty: %{"splice" => 0})
            |> Repo.update!()

          {Npcs.data_drop(player), player}
        end)

      assert Enum.any?(results, fn {result, _player} -> result == {:error, :npc_unreliable} end)

      assert Enum.all?(results, fn {result, player} ->
               case result do
                 {:error, :npc_unreliable} -> player.scrip == 25
                 _ -> true
               end
             end)
    end

    test "a favored-loyalty player gets a scaled (better) scrip cost" do
      player =
        Players.create_player!()
        |> Ecto.Changeset.change(scrip: 20, npc_loyalty: %{"splice" => 80})
        |> Repo.update!()

      assert {:ok, updated} = Npcs.data_drop(player)
      assert updated.scrip == 20 - ceil(20 * 0.8)
      assert updated.scrip == 4
    end

    test "a hostile-loyalty player gets a scaled (worse) scrip cost" do
      player =
        Players.create_player!()
        |> Ecto.Changeset.change(scrip: 25, npc_loyalty: %{"splice" => 24})
        |> Repo.update!()

      result =
        Enum.reduce_while(1..200, nil, fn _, _acc ->
          case Npcs.data_drop(player) do
            {:ok, updated} -> {:halt, updated}
            {:error, :npc_unreliable} -> {:cont, nil}
          end
        end)

      refute is_nil(result)
      assert result.scrip == 25 - ceil(20 * 1.25)
      assert result.scrip == 0
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

    test "a fresh player gains loyalty with tally on a successful settle" do
      player =
        Players.create_player!()
        |> Ecto.Changeset.change(cred: 1)
        |> Repo.update!()

      assert {:ok, updated} = Npcs.settle_the_books(player)
      assert updated.npc_loyalty["tally"] == 55
    end

    test "a hostile-loyalty player can get {:error, :npc_unreliable} without spending cred" do
      results =
        Enum.map(1..200, fn _ ->
          player =
            Players.create_player!()
            |> Ecto.Changeset.change(cred: 2, npc_loyalty: %{"tally" => 0})
            |> Repo.update!()

          {Npcs.settle_the_books(player), player}
        end)

      assert Enum.any?(results, fn {result, _player} -> result == {:error, :npc_unreliable} end)

      assert Enum.all?(results, fn {result, player} ->
               case result do
                 {:error, :npc_unreliable} -> player.cred == 2
                 _ -> true
               end
             end)
    end

    test "a favored-loyalty player gets a scaled (better) scrip gain" do
      player =
        Players.create_player!()
        |> Ecto.Changeset.change(cred: 1, scrip: 0, npc_loyalty: %{"tally" => 80})
        |> Repo.update!()

      assert {:ok, updated} = Npcs.settle_the_books(player)
      assert updated.scrip == floor(10 * 1.2)
      assert updated.scrip == 12
    end

    test "a hostile-loyalty player gets a scaled (worse) cred cost" do
      player =
        Players.create_player!()
        |> Ecto.Changeset.change(cred: 2, scrip: 0, npc_loyalty: %{"tally" => 24})
        |> Repo.update!()

      result =
        Enum.reduce_while(1..200, nil, fn _, _acc ->
          case Npcs.settle_the_books(player) do
            {:ok, updated} -> {:halt, updated}
            {:error, :npc_unreliable} -> {:cont, nil}
          end
        end)

      refute is_nil(result)
      assert result.cred == 2 - ceil(1 * 1.25)
      assert result.cred == 0
    end
  end
end
