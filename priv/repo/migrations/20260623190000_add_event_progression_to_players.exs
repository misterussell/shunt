defmodule Shunt.Repo.Migrations.AddEventProgressionToPlayers do
  use Ecto.Migration

  def change do
    # TODO: add the two event-progression columns, mirroring the style of
    # 20260623184313_add_location_to_players.exs:
    #   alter table(:players) do
    #     add :completed_events, {:array, :string}, default: [], null: false
    #     add :event_state, :map, default: %{}, null: false
    #   end
  end
end
