defmodule Shunt.Content.Store do
  @moduledoc false
  use GenServer

  @sources [
    {:npcs, "priv/content/npcs"},
    {:world_npcs, "priv/content/world_npcs"},
    {:fencing_items, "priv/content/fencing"},
    {:raws, "priv/content/raws"},
    {:recipes, "priv/content/recipes"},
    {:heat_events, "priv/content/heat_events"},
    {:skill_trees, "priv/content/skills"},
    {:locations, "priv/content/locations"},
    {:events, "priv/content/events"}
    # TODO: register {:quest_items, "priv/content/quest_items"} as a content source (the
    # generic load_source/2 already handles its %{id, name, flavor} map shape). Create that
    # directory with the errand quest items: juno_parcel, juno_delivery_receipt,
    # juno_pickup_chit, juno_pickup_goods, juno_supplier_dossier. Keeping them in their own
    # category (not :raws) is the safeguard: scavenge/RawCatalog, recipes, and fencing never
    # iterate :quest_items, so a quest item can't leak into those pools.
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

  def load_source(:world_npcs, dir) do
    entries =
      for file <- content_files(dir) do
        {npc, _bindings} = Code.eval_file(file)
        {npc.id, npc}
      end

    :ets.insert(:world_npcs, entries)
  end

  def load_source(:events, dir) do
    entries =
      for file <- content_files(dir) do
        {event, _bindings} = Code.eval_file(file)
        {event.id, event}
      end

    :ets.insert(:events, entries)
  end

  def load_source(table, dir) do
    entries =
      for file <- content_files(dir) do
        {item, _bindings} = Code.eval_file(file)
        {item.id, item}
      end

    :ets.insert(table, entries)
  end

  defp content_files(dir) do
    Path.wildcard(Path.join(Application.app_dir(:shunt, dir), "**/*.exs"))
  end
end
