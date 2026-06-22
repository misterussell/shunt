defmodule Shunt.Players.Player do
  use Ecto.Schema

  schema "players" do
    field :cred, :integer, default: 0
    field :scrip, :integer, default: 0
    field :heat, :integer, default: 0
    field :current_offer_key, :string
    field :held_item_key, :string

    field :ghostwork_tier, :integer, default: 0
    field :chrome_meat_tier, :integer, default: 0
    field :web_tier, :integer, default: 0
    field :street_alchemy_tier, :integer, default: 0

    field :inventory, :map, default: %{}

    # TODO: add `field :npc_loyalty, :map, default: %{}` here (same pattern as :inventory
    # above). Keys are NPC keys, values are integer loyalty 0-100; a missing key means the
    # player has never met that NPC yet. Backing migration:
    # priv/repo/migrations/20260622134144_add_npc_loyalty_to_players.exs

    timestamps()
  end
end
