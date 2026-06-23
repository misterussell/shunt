defmodule Shunt.NpcsTest do
  use ExUnit.Case, async: true

  alias Shunt.Fencing.Catalog
  alias Shunt.Npcs
  alias Shunt.Players.Player

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

  describe "can_flesh_tithe?/1" do
    test "returns true when the player holds at least 1 cracked_bone_plate" do
      player = %Player{inventory: %{"cracked_bone_plate" => 1}}

      assert Npcs.can_flesh_tithe?(player)
    end

    test "returns false when the player holds none" do
      player = %Player{inventory: %{}}

      refute Npcs.can_flesh_tithe?(player)
    end
  end

  describe "can_move_goods?/1" do
    test "returns true when the player holds an item" do
      player = %Player{held_item_key: "scrap_dermal_plating"}

      assert Npcs.can_move_goods?(player)
    end

    test "returns false when the player holds nothing" do
      player = %Player{held_item_key: nil}

      refute Npcs.can_move_goods?(player)
    end
  end

  describe "can_look_the_other_way?/1" do
    test "returns true when scrip covers the base cost" do
      player = %Player{scrip: 20}

      assert Npcs.can_look_the_other_way?(player)
    end

    test "returns false when scrip is below the base cost" do
      player = %Player{scrip: 19}

      refute Npcs.can_look_the_other_way?(player)
    end

    test "returns false when scrip covers the base cost but not the hostile-scaled cost" do
      player = %Player{scrip: 20, npc_loyalty: %{"nine_iron" => 0}}

      refute Npcs.can_look_the_other_way?(player)
    end

    test "returns true when scrip is below the base cost but a favored-scaled discount covers it" do
      player = %Player{scrip: 17, npc_loyalty: %{"nine_iron" => 80}}

      assert Npcs.can_look_the_other_way?(player)
    end
  end

  describe "can_data_drop?/1" do
    test "returns true when scrip covers the base cost" do
      player = %Player{scrip: 20}

      assert Npcs.can_data_drop?(player)
    end

    test "returns false when scrip covers the base cost but not the hostile-scaled cost" do
      player = %Player{scrip: 20, npc_loyalty: %{"splice" => 0}}

      refute Npcs.can_data_drop?(player)
    end
  end

  describe "can_settle_the_books?/1" do
    test "returns true when cred covers the base cost" do
      player = %Player{cred: 1}

      assert Npcs.can_settle_the_books?(player)
    end

    test "returns false when cred covers the base cost but not the hostile-scaled cost" do
      player = %Player{cred: 1, npc_loyalty: %{"tally" => 0}}

      refute Npcs.can_settle_the_books?(player)
    end
  end

  describe "flesh_tithe/1" do
    test "returns effects for consuming 1 cracked_bone_plate, heat, scrip, and npc_loyalty" do
      player = %Player{inventory: %{"cracked_bone_plate" => 1}}

      assert Npcs.flesh_tithe(player) ==
               {:ok,
                [
                  {:inventory, "cracked_bone_plate", -1},
                  {:heat, 5},
                  {:scrip, 15},
                  {:npc_loyalty, "mother_graft", 5}
                ]}
    end

    test "returns {:error, :insufficient_materials} when player holds none" do
      player = %Player{inventory: %{}}

      assert Npcs.flesh_tithe(player) == {:error, :insufficient_materials}
    end

    test "a favored-loyalty player gets a scaled (better) scrip gain effect" do
      player = %Player{
        inventory: %{"cracked_bone_plate" => 1},
        npc_loyalty: %{"mother_graft" => 80}
      }

      assert {:ok, effects} = Npcs.flesh_tithe(player)
      assert {:scrip, 18} in effects
    end

    test "a hostile-loyalty player gets a scaled (worse) scrip gain effect when reliable" do
      player = %Player{
        inventory: %{"cracked_bone_plate" => 1},
        npc_loyalty: %{"mother_graft" => 24}
      }

      result =
        Enum.reduce_while(1..200, nil, fn _, _acc ->
          case Npcs.flesh_tithe(player) do
            {:ok, effects} -> {:halt, effects}
            {:error, :npc_unreliable} -> {:cont, nil}
          end
        end)

      refute is_nil(result)
      assert {:scrip, 12} in result
    end

    test "a hostile-loyalty player can get {:error, :npc_unreliable}" do
      player = %Player{
        inventory: %{"cracked_bone_plate" => 1},
        npc_loyalty: %{"mother_graft" => 0}
      }

      results = Enum.map(1..200, fn _ -> Npcs.flesh_tithe(player) end)

      assert Enum.any?(results, &(&1 == {:error, :npc_unreliable}))
    end
  end

  describe "move_goods/1" do
    test "returns {:error, :no_held_item} when held_item_key is nil" do
      player = %Player{held_item_key: nil}

      assert Npcs.move_goods(player) == {:error, :no_held_item}
    end

    test "returns effects for 50% of the held item's sell_value, clearing held_item_key, and npc_loyalty" do
      item = Catalog.fetch!("scrap_dermal_plating")
      player = %Player{held_item_key: item.key}

      assert Npcs.move_goods(player) ==
               {:ok,
                [
                  {:scrip, floor(item.sell_value * 0.5)},
                  {:set, :held_item_key, nil},
                  {:npc_loyalty, "rook", 5}
                ]}
    end

    test "a favored-loyalty player gets a scaled (better) payout effect" do
      item = Catalog.fetch!("scrap_dermal_plating")
      player = %Player{held_item_key: item.key, npc_loyalty: %{"rook" => 80}}

      assert {:ok, effects} = Npcs.move_goods(player)
      assert {:scrip, floor(item.sell_value * 0.5 * 1.2)} in effects
    end

    test "a hostile-loyalty player gets a scaled (worse) payout effect when reliable" do
      item = Catalog.fetch!("scrap_dermal_plating")
      player = %Player{held_item_key: item.key, npc_loyalty: %{"rook" => 24}}

      result =
        Enum.reduce_while(1..200, nil, fn _, _acc ->
          case Npcs.move_goods(player) do
            {:ok, effects} -> {:halt, effects}
            {:error, :npc_unreliable} -> {:cont, nil}
          end
        end)

      refute is_nil(result)
      assert {:scrip, floor(item.sell_value * 0.5 * 0.8)} in result
    end

    test "a hostile-loyalty player can get {:error, :npc_unreliable}" do
      item = Catalog.fetch!("scrap_dermal_plating")
      player = %Player{held_item_key: item.key, npc_loyalty: %{"rook" => 0}}

      results = Enum.map(1..200, fn _ -> Npcs.move_goods(player) end)

      assert Enum.any?(results, &(&1 == {:error, :npc_unreliable}))
    end
  end

  describe "look_the_other_way/1" do
    test "returns {:error, :insufficient_scrip} when scrip < 20" do
      player = %Player{scrip: 19}

      assert Npcs.look_the_other_way(player) == {:error, :insufficient_scrip}
    end

    test "returns effects for the scrip cost, heat reduction, and npc_loyalty" do
      player = %Player{scrip: 20}

      assert Npcs.look_the_other_way(player) ==
               {:ok, [{:scrip, -20}, {:heat, -15}, {:npc_loyalty, "nine_iron", 5}]}
    end

    test "a favored-loyalty player gets a scaled (better) scrip cost effect" do
      player = %Player{scrip: 20, npc_loyalty: %{"nine_iron" => 80}}

      assert {:ok, effects} = Npcs.look_the_other_way(player)
      assert {:scrip, -ceil(20 * 0.8)} in effects
    end

    test "a hostile-loyalty player gets a scaled (worse) scrip cost effect when reliable" do
      player = %Player{scrip: 25, npc_loyalty: %{"nine_iron" => 24}}

      result =
        Enum.reduce_while(1..200, nil, fn _, _acc ->
          case Npcs.look_the_other_way(player) do
            {:ok, effects} -> {:halt, effects}
            {:error, :npc_unreliable} -> {:cont, nil}
          end
        end)

      refute is_nil(result)
      assert {:scrip, -ceil(20 * 1.25)} in result
    end

    test "a hostile-loyalty player can get {:error, :npc_unreliable}" do
      player = %Player{scrip: 25, npc_loyalty: %{"nine_iron" => 0}}

      results = Enum.map(1..200, fn _ -> Npcs.look_the_other_way(player) end)

      assert Enum.any?(results, &(&1 == {:error, :npc_unreliable}))
    end
  end

  describe "data_drop/1" do
    test "returns {:error, :insufficient_scrip} when scrip < 20" do
      player = %Player{scrip: 19}

      assert Npcs.data_drop(player) == {:error, :insufficient_scrip}
    end

    test "returns effects for the scrip cost, cred gain, and npc_loyalty" do
      player = %Player{scrip: 20}

      assert Npcs.data_drop(player) ==
               {:ok, [{:scrip, -20}, {:cred, 1}, {:npc_loyalty, "splice", 5}]}
    end

    test "a favored-loyalty player gets a scaled (better) scrip cost effect" do
      player = %Player{scrip: 20, npc_loyalty: %{"splice" => 80}}

      assert {:ok, effects} = Npcs.data_drop(player)
      assert {:scrip, -ceil(20 * 0.8)} in effects
    end

    test "a hostile-loyalty player gets a scaled (worse) scrip cost effect when reliable" do
      player = %Player{scrip: 25, npc_loyalty: %{"splice" => 24}}

      result =
        Enum.reduce_while(1..200, nil, fn _, _acc ->
          case Npcs.data_drop(player) do
            {:ok, effects} -> {:halt, effects}
            {:error, :npc_unreliable} -> {:cont, nil}
          end
        end)

      refute is_nil(result)
      assert {:scrip, -ceil(20 * 1.25)} in result
    end

    test "a hostile-loyalty player can get {:error, :npc_unreliable}" do
      player = %Player{scrip: 25, npc_loyalty: %{"splice" => 0}}

      results = Enum.map(1..200, fn _ -> Npcs.data_drop(player) end)

      assert Enum.any?(results, &(&1 == {:error, :npc_unreliable}))
    end
  end

  describe "settle_the_books/1" do
    test "returns {:error, :insufficient_cred} when cred < 1" do
      player = %Player{cred: 0}

      assert Npcs.settle_the_books(player) == {:error, :insufficient_cred}
    end

    test "returns effects for the cred cost, scrip gain, and npc_loyalty" do
      player = %Player{cred: 1}

      assert Npcs.settle_the_books(player) ==
               {:ok, [{:cred, -1}, {:scrip, 10}, {:npc_loyalty, "tally", 5}]}
    end

    test "a favored-loyalty player gets a scaled (better) scrip gain effect" do
      player = %Player{cred: 1, npc_loyalty: %{"tally" => 80}}

      assert {:ok, effects} = Npcs.settle_the_books(player)
      assert {:scrip, floor(10 * 1.2)} in effects
    end

    test "a hostile-loyalty player gets a scaled (worse) cred cost effect when reliable" do
      player = %Player{cred: 2, npc_loyalty: %{"tally" => 24}}

      result =
        Enum.reduce_while(1..200, nil, fn _, _acc ->
          case Npcs.settle_the_books(player) do
            {:ok, effects} -> {:halt, effects}
            {:error, :npc_unreliable} -> {:cont, nil}
          end
        end)

      refute is_nil(result)
      assert {:cred, -ceil(1 * 1.25)} in result
    end

    test "a hostile-loyalty player can get {:error, :npc_unreliable}" do
      player = %Player{cred: 2, npc_loyalty: %{"tally" => 0}}

      results = Enum.map(1..200, fn _ -> Npcs.settle_the_books(player) end)

      assert Enum.any?(results, &(&1 == {:error, :npc_unreliable}))
    end
  end
end
