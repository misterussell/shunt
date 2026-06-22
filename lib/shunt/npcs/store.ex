defmodule Shunt.Npcs.Store do
  @moduledoc false

  @table :npcs

  def all do
    ensure_loaded()
    Enum.map(:ets.tab2list(@table), fn {_key, npc} -> npc end)
  end

  def fetch!(key) do
    ensure_loaded()

    case :ets.lookup(@table, key) do
      [{_key, npc}] -> npc
      [] -> raise "unknown npc key: #{inspect(key)}"
    end
  end

  defp ensure_loaded do
    if :ets.whereis(@table) == :undefined do
      load_table()
    end
  end

  defp load_table do
    :ets.new(@table, [:set, :public, :named_table, read_concurrency: true])

    npcs_dir = Application.app_dir(:shunt, "priv/npcs")

    for file <- Path.wildcard(Path.join(npcs_dir, "*.exs")) do
      {npc, _bindings} = Code.eval_file(file)
      %{key: _, name: _, faction: _, loyalty: _, trade_actions: _} = npc
      :ets.insert(@table, {npc.key, npc})
    end
  rescue
    ArgumentError -> :ok
  end
end
