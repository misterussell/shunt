defmodule Shunt.Repo.Migrations.AddRumorsToPlayers do
  use Ecto.Migration

  def change do
    alter table(:players) do
      # TODO: add :rumors as {:array, :string} with default: [] and null: false,
      # mirroring the :knowledge and :contacts columns in add_web_ledger_to_players.exs
    end
  end
end
