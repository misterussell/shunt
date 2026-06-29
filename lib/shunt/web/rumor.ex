defmodule Shunt.Web.Rumor do
  @moduledoc false

  alias Shunt.Content

  # TODO: [recall] add an optional `origin: nil` field to the defstruct below — a one-line,
  # in-fiction note of where this kind of intel is learned (e.g. "Overheard in the Bazaar
  # back-rows"). Optional, NOT in @enforce_keys; the dossier's WHERE row falls back to `source`
  # when origin is nil.
  # TODO: [recall] author an `origin:` line for each existing rumor in priv/content/rumors/**/*.exs
  # per the SHUNT content docs (constitution/terminology/style/naming/lexicon). This is the WHERE
  # payload of the dossier. Leave nil only where no in-fiction origin fits.
  @enforce_keys [:id, :title, :description]
  defstruct [:id, :title, :description, source: nil, tags: []]

  def fetch!(id), do: Content.fetch!(:rumors, id)

  def fetch(id), do: Content.fetch(:rumors, id)

  def all, do: Content.all(:rumors)
end
