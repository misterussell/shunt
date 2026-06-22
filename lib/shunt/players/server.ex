defmodule Shunt.Players.Server do
  @moduledoc false
  use GenServer

  alias Shunt.Effects
  alias Shunt.Npcs.Signals
  alias Shunt.Players.Player
  alias Shunt.Repo

  def start_link(player_id) do
    GenServer.start_link(__MODULE__, player_id, name: via(player_id))
  end

  def current(pid) do
    GenServer.call(pid, :current)
  end

  defp via(player_id), do: {:via, Registry, {Shunt.Players.Registry, player_id}}

  @impl true
  def init(player_id) do
    {:ok, Repo.get!(Player, player_id)}
  end

  @impl true
  def handle_call(:current, _from, player), do: {:reply, player, player}

  def handle_call({:dispatch, resolver_fun}, _from, player) do
    case resolver_fun.(player) do
      {:ok, effects} -> dispatch_effects(player, effects, %{})
      {:ok, effects, extra_meta} -> dispatch_effects(player, effects, extra_meta)
      {:error, reason} -> {:reply, {:error, reason}, player}
    end
  end

  defp dispatch_effects(player, effects, extra_meta) do
    {changes, effect_meta} = Effects.apply(player, effects)

    case player |> Ecto.Changeset.change(changes) |> Repo.update() do
      {:ok, new_player} ->
        emit_signals(effect_meta.loyalty_signals)
        {:reply, {:ok, new_player, Map.merge(extra_meta, effect_meta)}, new_player}

      {:error, changeset} ->
        {:reply, {:error, changeset}, player}
    end
  end

  defp emit_signals(signals) do
    Enum.each(signals, fn
      {:npc_met, npc_key} ->
        Signals.npc_met(npc_key)

      {:loyalty_band_changed, npc_key, old_band, new_band} ->
        Signals.loyalty_band_changed(npc_key, old_band, new_band)
    end)
  end
end
