defmodule Shunt.Crafting.RawCatalog do
  @moduledoc false

  alias Shunt.Content

  def items, do: Content.all(:raws)

  def fetch!(key), do: Content.fetch!(:raws, key)
end
