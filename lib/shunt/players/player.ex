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
    field :npc_loyalty, :map, default: %{}

    # TODO: add `field :location_id, :string, default: "shunt9_player_squat"` and
    # `field :discovered_locations, {:array, :string}, default: []`. Needs a new
    # migration (mix ecto.gen.migration add_location_to_players) following the
    # precedent of add_npc_loyalty_to_players.exs, adding both columns with the
    # same defaults and `null: false`, so existing rows backfill to the starting
    # location.

    timestamps()
  end
end
