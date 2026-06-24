defmodule Shunt.Repo.Migrations.AddEventProgressionToPlayers do
  use Ecto.Migration

  def change do
    alter table(:players) do
      add :completed_events, {:array, :string}, default: [], null: false
      add :event_state, :map, default: %{}, null: false
    end
  end
end
