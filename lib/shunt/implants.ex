defmodule Shunt.Implants do
  @moduledoc """
  Accessor over the `:implants` content table (implant definitions). Thin wrapper on
  `Shunt.Content`, mirroring `Shunt.Crafting.RawCatalog` / `RecipeCatalog` / `Shunt.Ghostwork.Programs`.

  An implant def is a plain map exposing `.id`; see priv/content/implants/lineman_graft.exs for the
  shape (`chrome_load`, `heat_on_install`, `grants`, optional `fabrication`). Design:
  priv/docs/SHUNT_chrome_and_meat_v1.md.
  """

  # TODO: [Chrome & Meat v1 — Milestone 1] Implement accessors over Shunt.Content.all(:implants) /
  # Shunt.Content.fetch!(:implants, id):
  #   - items/0 -> all implant defs
  #   - fetch!/1 -> one def by id (raise on miss, like the other catalogs)
  # Requires the {:implants, "priv/content/implants"} source to be registered in
  # Shunt.Content.Store @sources (see the TODO there).
end
