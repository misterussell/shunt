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
    {:locations, "priv/content/locations"},
    {:events, "priv/content/events"}
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

  # TODO: add a load_source(:npcs, dir) clause here, above the generic load_source(table, dir)
  # clause below, that evals each file in priv/content/npcs and inserts entries keyed by
  # `npc.id` (mirroring this :events clause), since Shunt.World.NPC is a struct without a
  # :key field. Must come before the generic clause since Elixir matches in source order.
  #
  # Implement this in the same change as filling in the Shunt.World.NPC struct
  # (lib/shunt/world/npc.ex) and creating priv/content/npcs/shunt9_maintenance_tunnel_junkie.exs
  # (per priv/docs/SHUNT_npc_architecture.md "NPC Definition" section) — Content.Store
  # eagerly evaluates every .exs file under priv/content/npcs at app boot (it's in the
  # supervision tree), so a new npc content file with no matching loader clause, or a
  # loader clause with no matching content file shaped right, will crash `mix test`/`mix
  # phx.server` on startup. Land struct + loader clause + content file together.

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
        {item.key, item}
      end

    :ets.insert(table, entries)
  end

  defp content_files(dir) do
    Path.wildcard(Path.join(Application.app_dir(:shunt, dir), "**/*.exs"))
  end
end
