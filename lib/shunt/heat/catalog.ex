defmodule Shunt.Heat.Catalog do
  @moduledoc false

  # TODO: Define @events as a list of 9 maps, 3 per band (:low, :medium, :high), each shaped
  # %{key: string, band: :low | :medium | :high, name: string, flavor_text: string,
  # scrip_loss: non_neg_integer, cred_loss: non_neg_integer}. Follow the gdd.md Heat Event
  # flavor (KA raids, rival undercuts prices, Syndicate renegotiates, corp crackdown, etc).
  # Scale scrip_loss/cred_loss with band severity, e.g. :low ~5-15 scrip/0-2 cred,
  # :medium ~15-30 scrip/2-5 cred, :high ~30-60 scrip/5-10 cred. Mirror the
  # Shunt.Crafting.RecipeCatalog module attribute style.
  @events []

  # TODO: def events_for_band(band), do: Enum.filter(@events, &(&1.band == band))

  # TODO: def fetch!(key), do: Enum.find(@events, &(&1.key == key)) || raise "unknown heat event key: #{inspect(key)}"
end
