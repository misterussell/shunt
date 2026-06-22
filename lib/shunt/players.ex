defmodule Shunt.Players do
  alias Shunt.Repo
  alias Shunt.Players.Player

  @lay_low_cred_cost 10
  @lay_low_heat_reduction 20

  def create_player! do
    Repo.insert!(%Player{})
  end

  def get_player! do
    Repo.one!(Player)
  end

  def lay_low(%Player{cred: cred}) when cred < @lay_low_cred_cost do
    {:error, :insufficient_cred}
  end

  def lay_low(%Player{} = player) do
    player
    |> Ecto.Changeset.change(%{
      cred: max(player.cred - @lay_low_cred_cost, 0),
      heat: clamp_heat(player.heat - @lay_low_heat_reduction)
    })
    |> Repo.update()
  end

  defp clamp_heat(heat), do: heat |> max(0) |> min(100)
end
