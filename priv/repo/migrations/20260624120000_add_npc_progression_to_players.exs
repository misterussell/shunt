defmodule Shunt.Repo.Migrations.AddNpcProgressionToPlayers do
  use Ecto.Migration

  def change do
    alter table(:players) do
      add :npc_progression, :map, default: %{}, null: false
    end
  end
end
