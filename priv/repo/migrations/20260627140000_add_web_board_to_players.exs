defmodule Shunt.Repo.Migrations.AddWebBoardToPlayers do
  use Ecto.Migration

  def change do
    alter table(:players) do
      add :web_board, :map, default: %{"positions" => %{}, "wires" => []}, null: false
    end
  end
end
