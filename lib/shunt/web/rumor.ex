defmodule Shunt.Web.Rumor do
  @moduledoc false

  alias Shunt.Content

  # `origin` is an optional one-line, in-fiction note of where this kind of intel is learned
  # (e.g. "Overheard in the Bazaar back-rows"). The dossier's WHERE row falls back to `source`
  # when it's nil.
  @enforce_keys [:id, :title, :description]
  defstruct [:id, :title, :description, source: nil, origin: nil, tags: []]

  def fetch!(id), do: Content.fetch!(:rumors, id)

  def fetch(id), do: Content.fetch(:rumors, id)

  def all, do: Content.all(:rumors)
end
