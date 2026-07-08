defmodule Shunt.Web.Entity do
  @moduledoc false

  alias Shunt.Content

  # The entity kinds the Web can reference, mapped to the content table that resolves their ids.
  @tables %{npc: :world_npcs, location: :locations, ice: :ice_nodes}

  @doc """
  Resolves a `{kind, id}` reference to a display descriptor `%{key, kind, id, name}`, or `nil` when
  the kind is unknown or the id doesn't resolve. Dangling refs are dropped rather than surfaced, so
  a typo'd or content-removed id simply doesn't appear in the web.
  """
  def resolve({kind, id}) do
    with {:ok, table} <- Map.fetch(@tables, kind),
         {:ok, content} <- Content.fetch(table, id) do
      %{key: key(kind, id), kind: kind, id: id, name: name(content)}
    else
      _ -> nil
    end
  end

  def resolve(_), do: nil

  @doc "A DOM/CSS-safe stable key for an entity reference, e.g. `\"npc-shunt9_bazaar_juno\"`."
  def key(kind, id), do: "#{kind}-#{id}"

  # World NPC structs, location maps, and ICE structs all expose a `name`.
  defp name(%{name: name}), do: name
end
