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
    {:events, "priv/content/events"},
    # Quest items are carried errand items (parcels, chits, dossiers). They live in their own
    # category — not :raws — so scavenge/RawCatalog, recipes, and fencing never iterate them and
    # a quest item can't leak into those pools. The generic load_source/2 handles their
    # %{id, name, flavor} map shape.
    {:quest_items, "priv/content/quest_items"},
    # Ghostwork content categories. ICE nodes are breakable Latticework nodes (content files
    # build %Shunt.Ghostwork.IceNode{} structs); programs are deck-software items (plain
    # %{id, action, progress, trace, ...} maps). The generic load_source/2 handles both shapes
    # since each entry exposes .id. Directories may be empty until Phase 5 content lands.
    {:ice_nodes, "priv/content/ice_nodes"},
    {:programs, "priv/content/programs"},
    {:rumors, "priv/content/rumors"},
    {:rumor_connections, "priv/content/rumor_connections"},
    # Repairable infrastructure (generators, lifts, purifiers). Content files build
    # %Shunt.Repair.Repairable{} structs; the generic load_source/2 handles them via .id.
    {:repairables, "priv/content/repairables"},
    # District world-state defs (%Shunt.District.Def{}), the source of derived district facts.
    # The generic load_source/2 handles them via .id.
    {:districts, "priv/content/districts"},
    # Territory ladder + hideout modules (see priv/docs/SHUNT_territory_ladder_v1.md). The ladder
    # is a single def keyed "ladder"; modules are plain %{id, ...} upgrade defs. Generic
    # load_source/2 handles both via .id. The modules dir may be empty until content lands
    # (Path.wildcard returns [] and the table is created empty, like :ice_nodes/:programs).
    {:territory, "priv/content/territory"},
    {:modules, "priv/content/modules"}
    # TODO: [Chrome & Meat v1 — Milestone 1] Register the implant definition table (add a comma above):
    #   {:implants, "priv/content/implants"}
    # Generic load_source/2 handles it via .id (defs are plain maps). Dir already exists with the
    # lineman_graft stub; empty-dir is safe (Path.wildcard -> [], table created empty, like :modules).
    # Accessed via Shunt.Implants. See priv/docs/SHUNT_chrome_and_meat_v1.md.
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
