defmodule Shunt.Npcs.Store do
  @moduledoc false
  use GenServer

  # TODO: delete this entire module (and test/shunt/npcs/store_test.exs) once
  # Shunt.Content.Store (lib/shunt/content/store.ex) is implemented and wired into
  # lib/shunt/application.ex with an :npcs source pointed at priv/content/npcs - it covers
  # the exact same content this module loads from priv/npcs today. Move priv/npcs/*.exs to
  # priv/content/npcs/*.exs as part of that change. Shunt.Npcs.list/0 and Shunt.Npcs.get!/1
  # then delegate to Shunt.Content.all(:npcs) / Shunt.Content.fetch!(:npcs, key) instead of
  # this module.

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
        %{key: _, name: _, faction: _, trade_actions: _} = npc
        {npc.key, npc}
      end

    :ets.insert(@table, entries)

    {:ok, :ok}
  end
end
