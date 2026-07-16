defmodule Shunt.Repo.Migrations.DropWebBoardFromPlayers do
  use Ecto.Migration

  # The Web's drag-and-wire board is gone; the signal-network rework derives everything from
  # player.rumors and persists nothing here.
  def up do
    alter table(:players) do
      remove :web_board
    end
  end

  def down do
    alter table(:players) do
      add :web_board, :map, default: %{"positions" => %{}, "wires" => []}, null: false
    end
  end
end
