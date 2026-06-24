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
    # TODO: add `field :npc_progression, :map, default: %{}` (npc_key => integer stage),
    # mirroring npc_loyalty above, per priv/docs/SHUNT_npc_architecture.md "Player
    # Relationship State" section. Needs a migration: `mix ecto.gen.migration
    # add_npc_progression_to_players`, adding `add :npc_progression, :map, default: %{},
    # null: false` (same shape as the existing add_npc_loyalty_to_players migration).

    field :location_id, :string, default: "shunt9_player_squat"
    field :discovered_locations, {:array, :string}, default: []

    field :completed_events, {:array, :string}, default: []
    field :event_state, :map, default: %{}

    timestamps()
  end
end
