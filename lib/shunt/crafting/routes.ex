defmodule Shunt.Crafting.Routes do
  @moduledoc false

  # The six recipe routes — the single source of truth for the Street Alchemy Routing Filter
  # (rail chips + per-row stamps), in fixed display order. Fence is the residual route (a recipe
  # with no other downstream use). The CSS class per route is derived from the atom in the
  # template ("route--#{key}"), so colors live in app.css. Per-recipe route assignments live in
  # the recipe content files (routes: field), not here — this module holds only route metadata.
  @routes [
    %{key: :repair, label: "Repair"},
    %{key: :tools, label: "Tools"},
    %{key: :ghostwork, label: "Ghostwork"},
    %{key: :chrome_meat, label: "Chrome & Meat"},
    %{key: :web, label: "Web"},
    %{key: :fence, label: "Fence"}
  ]

  @labels Map.new(@routes, fn %{key: key, label: label} -> {key, label} end)

  def all, do: @routes

  def keys, do: Enum.map(@routes, & &1.key)

  def label(key), do: Map.fetch!(@labels, key)
end
