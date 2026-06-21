defmodule Shunt.Players.Player do
  use Ecto.Schema

  schema "players" do
    field :cred, :integer, default: 0
    field :scrip, :integer, default: 0
    field :heat, :integer, default: 0
    field :current_offer_key, :string
    field :held_item_key, :string

    timestamps()
  end
end
