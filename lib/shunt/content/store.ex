defmodule Shunt.Content.Store do
  @moduledoc false
  use GenServer

  @sources [
    {:npcs, "priv/content/npcs"},
    {:fencing_items, "priv/content/fencing"},
    {:raws, "priv/content/raws"},
    {:recipes, "priv/content/recipes"},
    {:heat_events, "priv/content/heat_events"},
    {:skill_trees, "priv/content/skills"}
  ]

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(:ok) do
    for {table, dir} <- @sources do
      :ets.new(table, [:set, :public, :named_table, read_concurrency: true])
      load_source(table, dir)
    end

    {:ok, :ok}
  end

  def load_source(:skill_trees, dir) do
    case content_files(dir) do
      [file] ->
        {trees, _bindings} = Code.eval_file(file)
        :ets.insert(:skill_trees, {:skill_trees, trees})

      [] ->
        :ok

      files ->
        raise "expected exactly one skill_trees content file, found #{length(files)}: #{inspect(files)}"
    end
  end

  def load_source(table, dir) do
    entries =
      for file <- content_files(dir) do
        {item, _bindings} = Code.eval_file(file)
        {item.key, item}
      end

    :ets.insert(table, entries)
  end

  defp content_files(dir) do
    Path.wildcard(Path.join(Application.app_dir(:shunt, dir), "*.exs"))
  end
end
