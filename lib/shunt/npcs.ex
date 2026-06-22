defmodule Shunt.Npcs do
  @moduledoc false
  alias Shunt.Npcs.Store

  def list do
    Enum.sort_by(Store.all(), & &1.name)
  end

  def get!(key) do
    Store.fetch!(key)
  end
end
