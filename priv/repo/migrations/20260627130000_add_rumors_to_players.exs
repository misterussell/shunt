defmodule Shunt.Repo.Migrations.AddRumorsToPlayers do
  use Ecto.Migration

  def change do
    alter table(:players) do
      add :rumors, {:array, :string}, default: [], null: false
    end
  end
end
