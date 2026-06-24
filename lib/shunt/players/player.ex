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

    field :location_id, :string, default: "shunt9_player_squat"
    field :discovered_locations, {:array, :string}, default: []

    # TODO: add event progression fields, via a migration mirroring
    # priv/repo/migrations/20260623184313_add_location_to_players.exs:
    #   field :completed_events, {:array, :string}, default: []
    #   field :event_state, :map, default: %{}   # %{"event_id" => %{"current_step" => "step_id"}}

    timestamps()
  end
end
