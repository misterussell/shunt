defmodule Shunt.Content do
  @moduledoc false

  def all(table) do
    Enum.map(:ets.tab2list(table), fn {_key, item} -> item end)
  end

  def fetch!(table, key) do
    case :ets.lookup(table, key) do
      [{_key, item}] -> item
      [] -> raise "unknown #{table} key: #{inspect(key)}"
    end
  end

  def fetch(table, key) do
    case :ets.lookup(table, key) do
      [{_key, item}] -> {:ok, item}
      [] -> :error
    end
  end
end
