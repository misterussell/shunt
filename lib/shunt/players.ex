defmodule Shunt.Players do
  import Ecto.Query

  alias Shunt.Repo
  alias Shunt.Players.Player

  @job_scrip_gain 15
  @job_cred_gain 5
  @job_heat_gain 10

  def get_or_create_player do
    case Repo.one(from p in Player, limit: 1) do
      nil -> Repo.insert!(%Player{})
      player -> player
    end
  end

  def do_job(%Player{} = player) do
    player
    |> Ecto.Changeset.change(%{
      scrip: player.scrip + @job_scrip_gain,
      cred: player.cred + @job_cred_gain,
      heat: clamp_heat(player.heat + @job_heat_gain)
    })
    |> Repo.update()
  end

  defp clamp_heat(heat), do: heat |> max(0) |> min(100)
end
