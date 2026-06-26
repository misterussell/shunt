defmodule Shunt.Repo.Migrations.AddWebLedgerToPlayers do
  use Ecto.Migration

  def change do
    # TODO: Add the three Web ledger columns to :players, matching the existing
    # not-null-with-default pattern (see AddNpcProgressionToPlayers):
    #   add :reputation, :map, default: %{}, null: false
    #   add :knowledge, {:array, :string}, default: [], null: false
    #   add :contacts,  {:array, :string}, default: [], null: false
  end
end
