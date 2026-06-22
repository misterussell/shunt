defmodule Shunt.CraftingTest do
  use Shunt.DataCase

  alias Shunt.Crafting
  alias Shunt.Crafting.RecipeCatalog
  alias Shunt.Players
  alias Shunt.Repo

  alias Shunt.Crafting.RawCatalog

  describe "scavenge/1" do
    test "adds one of a valid Raw to inventory and raises heat by 4, with no heat event" do
      player = Players.create_player!()

      {:ok, updated, nil} = Crafting.scavenge(player)

      assert updated.heat == player.heat + 4
      assert Enum.sum(Map.values(updated.inventory)) == Enum.sum(Map.values(player.inventory)) + 1
      raw_keys = Enum.map(RawCatalog.items(), & &1.key)
      assert Enum.all?(Map.keys(updated.inventory), &(&1 in raw_keys))
    end

    test "fires a heat event and discharges heat when crossing a Shunt.Heat band" do
      player =
        Players.create_player!()
        |> Ecto.Changeset.change(heat: 84, scrip: 100, cred: 100)
        |> Repo.update!()

      {:ok, updated, event} = Crafting.scavenge(player)

      assert event.band == :high
      assert updated.heat == 80
      assert updated.scrip == 100 - event.scrip_loss
      assert updated.cred == 100 - event.cred_loss
    end

    test "clamps heat at 100 with no event when already at the top of the :high band" do
      player =
        Players.create_player!()
        |> Ecto.Changeset.change(heat: 100)
        |> Repo.update!()

      {:ok, updated, nil} = Crafting.scavenge(player)

      assert updated.heat == 100
    end
  end

  describe "assemble/2" do
    test "consumes inputs and adds the output when tier and materials are sufficient" do
      recipe = RecipeCatalog.fetch!("patchwork_courier_drone")

      player =
        Players.create_player!()
        |> Ecto.Changeset.change(
          inventory: Map.put(recipe.inputs, "scrap_forged_soldering_iron", 1)
        )
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
        |> Ecto.Changeset.change(inventory: %{"scrap_forged_soldering_iron" => 1})
        |> Repo.update!()

      assert Crafting.assemble(player, "patchwork_courier_drone") ==
               {:error, :insufficient_materials}
    end

    test "tier_required: 0 recipes need no tool or tier" do
      recipe = RecipeCatalog.fetch!("scrap_forged_soldering_iron")

      player =
        Players.create_player!()
        |> Ecto.Changeset.change(inventory: recipe.inputs)
        |> Repo.update!()

      {:ok, updated} = Crafting.assemble(player, "scrap_forged_soldering_iron")

      assert updated.inventory["scrap_forged_soldering_iron"] == 1
    end
  end

  describe "sell_assembled/2" do
    test "pays scrip, cred, and heat, and decrements inventory, with no heat event" do
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

      {:ok, updated, nil} = Crafting.sell_assembled(player, "patchwork_courier_drone")

      assert updated.scrip == recipe.sell_value
      assert updated.cred == recipe.cred_gain
      assert updated.heat == recipe.heat_cost
      assert updated.inventory["patchwork_courier_drone"] == 0
    end

    test "fires a heat event and discharges heat when crossing a Shunt.Heat band" do
      recipe = RecipeCatalog.fetch!("patchwork_courier_drone")

      player =
        Players.create_player!()
        |> Ecto.Changeset.change(
          inventory: %{"patchwork_courier_drone" => 1},
          scrip: 0,
          cred: 0,
          heat: 25
        )
        |> Repo.update!()

      {:ok, updated, event} = Crafting.sell_assembled(player, "patchwork_courier_drone")

      assert event.band == :low
      assert updated.heat == 25
      assert updated.scrip == max(recipe.sell_value - event.scrip_loss, 0)
      assert updated.cred == max(recipe.cred_gain - event.cred_loss, 0)
    end

    test "returns :no_item when the player doesn't own one" do
      player = Players.create_player!()

      assert Crafting.sell_assembled(player, "patchwork_courier_drone") == {:error, :no_item}
    end
  end
end
