defmodule Shunt.Repo.Migrations.AddNpcLoyaltyToPlayers do
  use Ecto.Migration

  def change do
    # TODO: add :npc_loyalty, :map, default: %{}, null: false column to players, mirroring
    # the :inventory column added in 20260622045026_add_inventory_to_players.exs. Keys will be
    # NPC keys (e.g. "mother_graft"), values integer loyalty 0-100; absence of a key means the
    # player has never met that NPC.
  end
end
