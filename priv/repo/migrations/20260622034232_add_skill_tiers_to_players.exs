defmodule Shunt.Repo.Migrations.AddSkillTiersToPlayers do
  use Ecto.Migration

  def change do
    # TODO: add :ghostwork_tier, :chrome_meat_tier, :web_tier, :street_alchemy_tier as
    # non-null :integer columns on :players, default: 0 (mirrors :cred/:scrip/:heat
    # pattern from 20260621211053_create_players.exs)
  end
end
