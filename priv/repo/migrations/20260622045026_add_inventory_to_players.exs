defmodule Shunt.Repo.Migrations.AddInventoryToPlayers do
  use Ecto.Migration

  def change do
    alter table(:players) do
      add :inventory, :map, default: %{}, null: false
    end
  end
end
