defmodule Shunt.Repo.Migrations.AddWebLedgerToPlayers do
  use Ecto.Migration

  def change do
    alter table(:players) do
      add :reputation, :map, default: %{}, null: false
      add :knowledge, {:array, :string}, default: [], null: false
      add :contacts, {:array, :string}, default: [], null: false
    end
  end
end
