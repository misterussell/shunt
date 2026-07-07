defmodule Shunt.Crafting.Routes do
  @moduledoc false

  # TODO: Define the six recipe routes as the single source of truth for the Street Alchemy
  # Routing Filter (rail chips + per-row stamps). Provide, in this fixed display order:
  #
  #   {:repair, "Repair"}, {:tools, "Tools"}, {:ghostwork, "Ghostwork"},
  #   {:chrome_meat, "Chrome & Meat"}, {:web, "Web"}, {:fence, "Fence"}
  #
  # Expose:
  #   all/0        -> ordered list of %{key: atom, label: String.t()} for the six routes
  #   keys/0       -> ordered list of the six route atoms (for validation/tests)
  #   label/1      -> label for a route key
  #
  # The CSS class per route is derived from the atom in the template (e.g. "route--#{key}"),
  # so colors live in app.css, not here. Per-recipe route assignments live in the recipe
  # content files (routes: field), NOT in this module — this module only holds route metadata.
end
