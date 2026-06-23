defmodule Shunt.Players do
  @moduledoc false
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
          {:error, _reason} -> {:error, :not_found}
        end
    end
  end

  def dispatch(player_id, resolver_fun) do
    with {:ok, pid} <- lookup_or_start(player_id) do
      GenServer.call(pid, {:dispatch, resolver_fun})
    end
  end

  def current(player_id) do
    with {:ok, pid} <- lookup_or_start(player_id) do
      Server.current(pid)
    end
  end

  def can_lay_low?(%Player{cred: cred}), do: cred >= @lay_low_cred_cost

  def lay_low(%Player{cred: cred}) when cred < @lay_low_cred_cost do
    {:error, :insufficient_cred}
  end

  def lay_low(%Player{}) do
    {:ok, [{:cred, -@lay_low_cred_cost}, {:heat, -@lay_low_heat_reduction}]}
  end
end
