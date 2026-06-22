defmodule Shunt.Repo.Migrations.AddNpcLoyaltyToPlayers do
  use Ecto.Migration

  def change do
    alter table(:players) do
      add :npc_loyalty, :map, default: %{}, null: false
    end
  end
end
