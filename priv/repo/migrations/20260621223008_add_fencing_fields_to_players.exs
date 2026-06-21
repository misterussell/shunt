defmodule Shunt.Repo.Migrations.AddFencingFieldsToPlayers do
  use Ecto.Migration

  def change do
    alter table(:players) do
      add :current_offer_key, :string
      add :held_item_key, :string
    end
  end
end
