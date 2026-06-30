defmodule Shunt.Repo.Migrations.AddTerritoryToPlayers do
  use Ecto.Migration

  def change do
    alter table(:players) do
      add :premises_id, :string, null: false, default: "shunt9_player_squat"
      add :modules, {:array, :string}, null: false, default: []
      add :last_collected, :utc_datetime
    end
  end
end
