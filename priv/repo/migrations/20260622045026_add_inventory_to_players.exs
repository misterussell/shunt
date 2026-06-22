defmodule Shunt.Repo.Migrations.AddInventoryToPlayers do
  use Ecto.Migration

  def change do
    # TODO: add :inventory as a non-null :map column on :players, default: %{}
    # (generic item_key string => quantity integer store, shared by Raw materials and
    # Assembled goods — mirrors the :cred/:scrip/:heat pattern from
    # 20260621211053_create_players.exs)
  end
end
