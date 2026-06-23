defmodule Shunt.Repo.Migrations.AddLocationToPlayers do
  use Ecto.Migration

  def change do
    alter table(:players) do
      add :location_id, :string, default: "shunt9_player_squat", null: false
      add :discovered_locations, {:array, :string}, default: [], null: false
    end
  end
end
