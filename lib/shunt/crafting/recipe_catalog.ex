defmodule Shunt.Crafting.RecipeCatalog do
  @moduledoc false

  alias Shunt.Content

  def recipes, do: Content.all(:recipes)

  def fetch!(key), do: Content.fetch!(:recipes, key)
end
