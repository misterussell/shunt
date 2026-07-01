defmodule Shunt.Repo.Migrations.AddChromeToPlayers do
  use Ecto.Migration

  # TODO: [Chrome & Meat v1 — Milestone 1] Add Chrome & Meat player state:
  #   add :chrome_load, :integer, default: 0, null: false   # capped 0–100 meter (Chrome Load)
  #   add :implants, :map, default: %{}, null: false         # def-keyed %{implant_key => %{...}}
  # Mirror the additive, single-field migrations in this dir (e.g.
  # 20260627150000_add_infrastructure_to_players.exs). Keep it additive — no backfill needed;
  # existing players default to chrome_load 0 / no implants.
  def change do
  end
end
