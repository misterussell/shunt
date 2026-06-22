defmodule Shunt.Fencing.Catalog do
  @moduledoc false

  alias Shunt.Content

  def items, do: Content.all(:fencing_items)

  def fetch!(key), do: Content.fetch!(:fencing_items, key)
end
