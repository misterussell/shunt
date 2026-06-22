defmodule Shunt.Players.Player do
  use Ecto.Schema

  schema "players" do
    field :cred, :integer, default: 0
    field :scrip, :integer, default: 0
    field :heat, :integer, default: 0
    field :current_offer_key, :string
    field :held_item_key, :string

    # TODO: add :ghostwork_tier, :chrome_meat_tier, :web_tier, :street_alchemy_tier
    # fields, :integer, default: 0 — matches the columns added in
    # 20260622034232_add_skill_tiers_to_players.exs

    timestamps()
  end
end
