defmodule Shunt.Repo.Migrations.AddInfrastructureToPlayers do
  use Ecto.Migration

  def change do
    alter table(:players) do
      add :infrastructure, :map, default: %{}, null: false
    end
  end
end
