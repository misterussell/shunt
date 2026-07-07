defmodule Shunt.Crafting.RecipeCatalog do
  @moduledoc false

  alias Shunt.Content

  # TODO: Back-fill a `routes: [atom]` list field on all 13 recipe content files in
  # priv/content/recipes/*.exs (Routing Filter). Each list holds one or more route keys from
  # Shunt.Crafting.Routes.keys/0. Authoritative mapping (Fence is the residual — assigned only
  # when a recipe has no other downstream use):
  #   standard_relay, military_relay, improvised_relay        -> [:repair]
  #   scrap_forged_soldering_iron, precision_toolkit, diagnostic_probe -> [:tools]
  #   jury_rigged_terminal   -> [:ghostwork]
  #   patchwork_scalpel      -> [:chrome_meat]
  #   burner_ledger, forgers_stub -> [:web]
  #   splice_tap_relay, jury_rigged_stim_rig, patchwork_courier_drone -> [:fence]
  # The field is a list so a future recipe can carry two routes (e.g. [:tools, :fence]); all 13
  # current recipes take exactly one.
  def recipes, do: Content.all(:recipes)

  def fetch!(key), do: Content.fetch!(:recipes, key)
end
