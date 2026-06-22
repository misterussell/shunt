defmodule Shunt.Npcs.Store do
  @moduledoc false
  use GenServer

  @table :npcs

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def all do
    Enum.map(:ets.tab2list(@table), fn {_key, npc} -> npc end)
  end

  def fetch!(key) do
    case :ets.lookup(@table, key) do
      [{_key, npc}] -> npc
      [] -> raise "unknown npc key: #{inspect(key)}"
    end
  end

  @impl true
  def init(:ok) do
    :ets.new(@table, [:set, :public, :named_table, read_concurrency: true])

    npcs_dir = Application.app_dir(:shunt, "priv/npcs")

    entries =
      for file <- Path.wildcard(Path.join(npcs_dir, "*.exs")) do
        {npc, _bindings} = Code.eval_file(file)
        %{key: _, name: _, faction: _, loyalty: _, trade_actions: _} = npc
        # TODO: drop `loyalty: _` from this pattern match once every priv/npcs/*.exs file's
        # static `loyalty:` field is removed (loyalty now lives on Player.npc_loyalty, read
        # via Shunt.Npcs.Loyalty.value/2 — NPC structs no longer carry per-player data).
        {npc.key, npc}
      end

    :ets.insert(@table, entries)

    {:ok, :ok}
  end
end
