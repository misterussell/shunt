defmodule Shunt.Repo.Migrations.AddInfrastructureToPlayers do
  use Ecto.Migration

  def change do
    # TODO: add `:infrastructure, :map, default: %{}` column to players, mirroring the
    #   existing add_*_to_players map-column migrations (e.g. add_web_board_to_players).
  end
end
