defmodule Shunt.Repo.Migrations.AddChromeToPlayers do
  use Ecto.Migration

  def change do
    alter table(:players) do
      # Chrome Load — capped 0–100 meter, distinct from :heat.
      add :chrome_load, :integer, default: 0, null: false
      # Def-keyed installed-implant state: %{implant_key => %{...}}. Mirrors :infrastructure.
      add :implants, :map, default: %{}, null: false
    end
  end
end
