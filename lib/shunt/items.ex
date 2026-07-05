defmodule Shunt.Items do
  @moduledoc false

  # Content tables that hold grantable, named inventory items, in lookup order. Any category an
  # event/NPC can grant via {:inventory, key, n} must be listed here or reward display crashes.
  @item_tables [:raws, :quest_items, :chrome_raws, :implants]

  def display_name(key) do
    Enum.find_value(@item_tables, fn table ->
      case :ets.lookup(table, key) do
        [{_key, item}] -> item.name
        [] -> nil
      end
    end) || raise "unknown item key: #{inspect(key)}"
  end
end
