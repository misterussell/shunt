defmodule Shunt.Repo.Migrations.CreatePlayers do
  use Ecto.Migration

  def change do
    create table(:players) do
      add :cred, :integer, default: 0, null: false
      add :scrip, :integer, default: 0, null: false
      add :heat, :integer, default: 0, null: false

      timestamps()
    end
  end
end
