defmodule Shunt.Npcs.Store do
  @moduledoc false

  @table :npcs

  # TODO: implement all/0 — call ensure_loaded/0, then return every NPC map via
  # :ets.tab2list(@table) |> Enum.map(fn {_key, npc} -> npc end)
  def all do
  end

  # TODO: implement fetch!/1 — call ensure_loaded/0, then :ets.lookup(@table, key).
  # On a match, return the npc map. On no match, raise "unknown npc key: #{inspect(key)}".
  def fetch!(key) do
  end

  # TODO: implement ensure_loaded/0 — if :ets.whereis(@table) is :undefined, create the table
  # with :ets.new(@table, [:set, :public, :named_table, read_concurrency: true]), then for every
  # file matched by Path.wildcard(Path.join(Application.app_dir(:shunt, "priv/npcs"), "*.exs")),
  # evaluate it with {npc, _bindings} = Code.eval_file(file), pattern-match
  # %{key: _, name: _, faction: _, loyalty: _, trade_actions: _} = npc to fail loudly on a
  # malformed file, and :ets.insert(@table, {npc.key, npc}).
  # Wrap the :ets.new/2 call in try/rescue ArgumentError -> :ok to handle the race where another
  # process created the table first — in that case skip population, the winner already did it.
  defp ensure_loaded do
  end
end
