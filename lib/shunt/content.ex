defmodule Shunt.Content do
  @moduledoc false

  # TODO: implement all(table) delegating to
  # Enum.map(:ets.tab2list(table), fn {_key, item} -> item end), mirroring
  # Shunt.Npcs.Store.all/0 today. Used by catalog modules (e.g. Shunt.Fencing.Catalog.items/0)
  # once they delegate into Shunt.Content.Store (lib/shunt/content/store.ex) instead of a
  # hardcoded module attribute.

  # TODO: implement fetch!(table, key), delegating to :ets.lookup(table, key) and raising
  # "unknown #{table} key: #{inspect(key)}" when the lookup returns [], mirroring
  # Shunt.Npcs.Store.fetch!/1 today.
end
