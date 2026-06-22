defmodule Shunt.Repo.Migrations.AddSkillTiersToPlayers do
  use Ecto.Migration

  def change do
    alter table(:players) do
      add :ghostwork_tier, :integer, null: false, default: 0
      add :chrome_meat_tier, :integer, null: false, default: 0
      add :web_tier, :integer, null: false, default: 0
      add :street_alchemy_tier, :integer, null: false, default: 0
    end
  end
end
