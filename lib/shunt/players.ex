defmodule Shunt.Players do
  import Ecto.Query

  alias Shunt.Repo
  alias Shunt.Players.Player

  def get_or_create_player do
    case Repo.one(from p in Player, limit: 1) do
      nil -> Repo.insert!(%Player{})
      player -> player
    end
  end
end
