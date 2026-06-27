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
    field :npc_progression, :map, default: %{}

    field :reputation, :map, default: %{}
    field :knowledge, {:array, :string}, default: []
    field :contacts, {:array, :string}, default: []
    field :rumors, {:array, :string}, default: []

    # TODO: add `field :web_board, :map, default: %{"positions" => %{}, "wires" => []}` here, backed
    # by a new migration `add :web_board, :map, default: %{}` on the players table. `positions` maps
    # rumor_id => %{"x" => float_0_1, "y" => float_0_1} (fractional board coords); `wires` is a list
    # of sorted [id_a, id_b] string pairs. A rumor is "on the board" iff it has a positions entry;
    # everything else in player.rumors is intake.

    field :ghostwork_state, :map, default: %{}

    field :location_id, :string, default: "shunt9_player_squat"
    field :discovered_locations, {:array, :string}, default: []

    field :completed_events, {:array, :string}, default: []
    field :event_state, :map, default: %{}

    timestamps()
  end
end
