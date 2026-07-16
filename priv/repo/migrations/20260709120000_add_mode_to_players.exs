defmodule Shunt.Repo.Migrations.AddModeToPlayers do
  use Ecto.Migration

  def change do
    alter table(:players) do
      # Character mode (see priv/docs/SHUNT_laying_low_v2.md). nil = normal; "laying_low" = the mode.
      add :mode, :string
    end
  end
end
