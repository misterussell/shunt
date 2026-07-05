defmodule Shunt.Implants do
  @moduledoc """
  Accessor over the `:implants` content table (implant definitions). Thin wrapper on
  `Shunt.Content`, mirroring `Shunt.Crafting.RawCatalog` / `RecipeCatalog` / `Shunt.Ghostwork.Programs`.

  An implant def is a plain map exposing `.id`; see priv/content/implants/lineman_graft.exs for the
  shape (`chrome_load`, `heat_on_install`, `grants`, optional `fabrication`). Design:
  priv/docs/SHUNT_chrome_and_meat_v1.md.
  """

  alias Shunt.Content

  def items, do: Content.all(:implants)

  def fetch!(key), do: Content.fetch!(:implants, key)
end
