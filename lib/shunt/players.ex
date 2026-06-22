defmodule Shunt.Players do
  @moduledoc false
  alias Shunt.Heat
  alias Shunt.Repo
  alias Shunt.Players.Player
  alias Shunt.Players.Server

  @lay_low_cred_cost 10
  @lay_low_heat_reduction 20

  def create_player! do
    Repo.insert!(%Player{})
  end

  def get_player! do
    Repo.one!(Player)
  end

  def lookup_or_start(player_id) do
    case Registry.lookup(Shunt.Players.Registry, player_id) do
      [{pid, _}] ->
        {:ok, pid}

      [] ->
        case DynamicSupervisor.start_child(Shunt.Players.Supervisor, {Server, player_id}) do
          {:ok, pid} -> {:ok, pid}
          {:error, {:already_started, pid}} -> {:ok, pid}
        end
    end
  end

  def dispatch(player_id, resolver_fun) do
    {:ok, pid} = lookup_or_start(player_id)
    GenServer.call(pid, {:dispatch, resolver_fun})
  end

  def current(player_id) do
    {:ok, pid} = lookup_or_start(player_id)
    Server.current(pid)
  end

  def lay_low(%Player{cred: cred}) when cred < @lay_low_cred_cost do
    {:error, :insufficient_cred}
  end

  def lay_low(%Player{} = player) do
    # TODO: per priv/docs/architecture.md Section 3, return {:ok, [{:cred, -@lay_low_cred_cost},
    # {:heat, -@lay_low_heat_reduction}]} instead of calling Ecto.Changeset.change/Repo.update
    # directly, same pattern as Shunt.Fencing/Shunt.Crafting/Shunt.Npcs. Remove the
    # `alias Shunt.Heat` and `alias Shunt.Repo` lines once this and create_player!/0 and
    # get_player!/0 (which still need Repo) are the only Repo-touching code left here.
    player
    |> Ecto.Changeset.change(%{
      cred: max(player.cred - @lay_low_cred_cost, 0),
      heat: Heat.clamp(player.heat - @lay_low_heat_reduction)
    })
    |> Repo.update()
  end
end
