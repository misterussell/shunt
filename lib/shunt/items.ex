defmodule Shunt.Items do
  @moduledoc false

  def display_name(key) do
    case :ets.lookup(:raws, key) do
      [{_key, item}] -> item.name
      [] ->
        case :ets.lookup(:quest_items, key) do
          [{_key, item}] -> item.name
          [] -> raise "unknown item key: #{inspect(key)}"
        end
    end
  end
end
