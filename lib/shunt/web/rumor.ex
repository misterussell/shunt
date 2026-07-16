defmodule Shunt.Web.Rumor do
  @moduledoc false

  alias Shunt.Content

  # `origin` is an optional one-line, in-fiction note of where this kind of intel is learned
  # (e.g. "Overheard in the Bazaar back-rows"). The dossier's WHERE row falls back to `source`
  # when it's nil.
  #
  # `entities` are the real game objects this intel names — `{:npc, id}` / `{:location, id}` /
  # `{:ice, id}`, resolved by `Shunt.Web.Entity`. The Web weaves its graph from these: a thread
  # means two entities were named in the same rumor. `tags` is legacy and no longer drives the Web.
  @enforce_keys [:id, :title, :description]
  defstruct [:id, :title, :description, source: nil, origin: nil, tags: [], entities: []]

  def fetch!(id), do: Content.fetch!(:rumors, id)

  def fetch(id), do: Content.fetch(:rumors, id)

  def all, do: Content.all(:rumors)
end
