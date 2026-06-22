defmodule Shunt.Players do
  @moduledoc false
  alias Shunt.Heat
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

  # TODO: per priv/docs/architecture.md Section 1, implement lookup_or_start(player_id)
  # returning the pid of an already-running Shunt.Players.Server for player_id, or starting
  # one under Shunt.Players.Supervisor (via DynamicSupervisor.start_child/2) if none is
  # running yet. Use Registry.lookup(Shunt.Players.Registry, player_id) to check first, since
  # DynamicSupervisor.start_child/2 with a :via name will return
  # {:error, {:already_started, pid}} on a race rather than silently reusing the pid - handle
  # that case by returning the existing pid instead of treating it as an error.

  # TODO: implement dispatch(player_id, resolver_fun), which calls lookup_or_start/1 then
  # GenServer.call(pid, {:dispatch, resolver_fun}). See Shunt.Players.Server's TODO for what
  # resolver_fun must look like and what dispatch/2 returns.

  # TODO: implement current(player_id_or_pid) delegating to Shunt.Players.Server.current/1,
  # used by ShuntWeb.DashboardLive.mount/3 to read the in-memory player after
  # lookup_or_start/1.

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
