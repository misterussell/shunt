defmodule Shunt.CraftingTest do
  use Shunt.DataCase

  alias Shunt.Crafting
  alias Shunt.Crafting.RecipeCatalog
  alias Shunt.Players
  alias Shunt.Repo

  alias Shunt.Crafting.RawCatalog

  describe "scavenge/1" do
    test "adds one of a valid Raw to inventory and raises heat by 4" do
      player = Players.create_player!()

      {:ok, updated} = Crafting.scavenge(player)

      assert updated.heat == player.heat + 4
      assert Enum.sum(Map.values(updated.inventory)) == Enum.sum(Map.values(player.inventory)) + 1
      raw_keys = Enum.map(RawCatalog.items(), & &1.key)
      assert Enum.all?(Map.keys(updated.inventory), &(&1 in raw_keys))
    end

    test "clamps heat at 100" do
      player =
        Players.create_player!()
        |> Ecto.Changeset.change(heat: 99)
        |> Repo.update!()

      {:ok, updated} = Crafting.scavenge(player)

      assert updated.heat == 100
    end
  end

  describe "assemble/2" do
    test "consumes inputs and adds the output when tier and materials are sufficient" do
      recipe = RecipeCatalog.fetch!("patchwork_courier_drone")

      player =
        Players.create_player!()
        |> Ecto.Changeset.change(street_alchemy_tier: 1, inventory: recipe.inputs)
        |> Repo.update!()

      {:ok, updated} = Crafting.assemble(player, "patchwork_courier_drone")

      for {raw_key, qty} <- recipe.inputs do
        assert Map.get(updated.inventory, raw_key, 0) == Map.get(recipe.inputs, raw_key) - qty
      end

      assert updated.inventory["patchwork_courier_drone"] == 1
    end

    test "returns :insufficient_tier when street_alchemy_tier is below the requirement" do
      player = Players.create_player!()

      assert Crafting.assemble(player, "patchwork_courier_drone") == {:error, :insufficient_tier}
    end

    test "returns :insufficient_materials when an input quantity is missing" do
      player =
        Players.create_player!()
        |> Ecto.Changeset.change(street_alchemy_tier: 1)
        |> Repo.update!()

      assert Crafting.assemble(player, "patchwork_courier_drone") ==
               {:error, :insufficient_materials}
    end
  end

  describe "sell_assembled/2" do
    test "pays scrip, cred, and heat, and decrements inventory" do
      recipe = RecipeCatalog.fetch!("patchwork_courier_drone")

      player =
        Players.create_player!()
        |> Ecto.Changeset.change(
          inventory: %{"patchwork_courier_drone" => 1},
          scrip: 0,
          cred: 0,
          heat: 0
        )
        |> Repo.update!()

      {:ok, updated} = Crafting.sell_assembled(player, "patchwork_courier_drone")

      assert updated.scrip == recipe.sell_value
      assert updated.cred == recipe.cred_gain
      assert updated.heat == recipe.heat_cost
      assert updated.inventory["patchwork_courier_drone"] == 0
    end

    test "returns :no_item when the player doesn't own one" do
      player = Players.create_player!()

      assert Crafting.sell_assembled(player, "patchwork_courier_drone") == {:error, :no_item}
    end
  end
end
