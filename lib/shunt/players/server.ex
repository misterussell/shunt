defmodule Shunt.Players.Server do
  @moduledoc false
  use GenServer

  # TODO: implement start_link(player_id) as
  # GenServer.start_link(__MODULE__, player_id, name: via(player_id)), and a private
  # via(player_id) helper returning {:via, Registry, {Shunt.Players.Registry, player_id}}.
  # init(player_id) should load state with Shunt.Repo.get!(Shunt.Players.Player, player_id).

  # TODO: implement current(pid) :: Shunt.Players.Player.t() via GenServer.call(pid, :current),
  # and the matching handle_call(:current, _from, player) clause replying {:reply, player, player}.

  # TODO: implement handle_call({:dispatch, resolver_fun}, _from, player), where resolver_fun
  # is (Player.t() -> {:ok, list()} | {:ok, list(), map()} | {:error, term()}):
  #   - call resolver_fun.(player)
  #   - on {:ok, effects} or {:ok, effects, extra_meta}: run
  #     {changes, effect_meta} = Shunt.Effects.apply(player, effects), then
  #     player |> Ecto.Changeset.change(changes) |> Shunt.Repo.update()
  #     - on {:ok, new_player}: emit signals from effect_meta.loyalty_signals via
  #       Shunt.Npcs.Signals.npc_met/1 and Shunt.Npcs.Signals.loyalty_band_changed/3 (only
  #       after the persist succeeds), reply {:reply, {:ok, new_player,
  #       Map.merge(extra_meta || %{}, effect_meta)}, new_player}
  #     - on {:error, changeset}: reply {:reply, {:error, changeset}, player} (state unchanged)
  #   - on {:error, reason}: reply {:reply, {:error, reason}, player} (state unchanged, no
  #     Shunt.Effects.apply call)
end
