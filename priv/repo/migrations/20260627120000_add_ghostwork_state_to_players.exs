defmodule Shunt.Repo.Migrations.AddGhostworkStateToPlayers do
  use Ecto.Migration

  def change do
    alter table(:players) do
      add :ghostwork_state, :map, default: %{}, null: false
    end
  end
end
