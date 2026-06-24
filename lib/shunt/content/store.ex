defmodule Shunt.Content.Store do
  @moduledoc false
  use GenServer

  @sources [
    {:npcs, "priv/content/npcs"},
    {:fencing_items, "priv/content/fencing"},
    {:raws, "priv/content/raws"},
    {:recipes, "priv/content/recipes"},
    {:heat_events, "priv/content/heat_events"},
    {:skill_trees, "priv/content/skills"},
    {:locations, "priv/content/locations"}
    # TODO: add {:events, "priv/content/events"} once Shunt.Events.Event exists and
    # priv/content/events/shunt9/*.exs has been authored (see priv/docs/SHUNT_event_system.md).
  ]

  # TODO: move priv/content/locations/*.exs into priv/content/locations/shunt9/ (all 7
  # files, unchanged contents) to match the zone-based layout used by priv/content/events/shunt9/.
  # Requires the content_files/1 wildcard change below first.

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
    # TODO: change "*.exs" to "**/*.exs" so nested zone directories (e.g.
    # priv/content/locations/shunt9/, priv/content/events/shunt9/) load alongside the
    # existing flat content dirs. Elixir's ** matches zero-or-more directories, so this is a
    # one-line change that doesn't affect the currently-flat sources (npcs, raws, etc).
    Path.wildcard(Path.join(Application.app_dir(:shunt, dir), "*.exs"))
  end
end
