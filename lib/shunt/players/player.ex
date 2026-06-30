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

    # Investigation board layout. `positions` maps rumor_id => %{"x" => f, "y" => f} (fractional
    # 0–1 board coords); `wires` is a list of sorted [id_a, id_b] string pairs. A rumor is "on the
    # board" iff it has a positions entry; everything else in player.rumors is intake.
    field :web_board, :map, default: %{"positions" => %{}, "wires" => []}

    field :ghostwork_state, :map, default: %{}

    # repairable_id => "broken" | "patched" | "repaired". Absence of a key means the
    # repairable's initial_state (resolved by Shunt.Repair.state/2).
    field :infrastructure, :map, default: %{}

    # TODO: [Territory] Add three Territory fields (see priv/docs/SHUNT_territory_ladder_v1.md §3):
    #   field :premises_id, :string, default: "shunt9_player_squat"  # home base location; distinct
    #     from :location_id (current location). Relocation sets this.
    #   field :modules, {:array, :string}, default: []  # installed module keys; append-only in v1.
    #   field :last_collected, :utc_datetime  # timestamp the income reservoir is computed from; nil
    #     until the first income module, set on collect.
    # Create migration priv/repo/migrations/20260630120000_add_territory_to_players.exs adding the
    # three columns with these defaults (premises_id default "shunt9_player_squat", modules default []).
    field :location_id, :string, default: "shunt9_player_squat"
    field :discovered_locations, {:array, :string}, default: []

    field :completed_events, {:array, :string}, default: []
    field :event_state, :map, default: %{}

    timestamps()
  end
end
