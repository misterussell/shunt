defmodule Shunt.Web.Rumor do
  @moduledoc false

  alias Shunt.Content

  @enforce_keys [:id, :title, :description]
  defstruct [:id, :title, :description, source: nil, tags: []]

  def fetch!(id), do: Content.fetch!(:rumors, id)

  def all, do: Content.all(:rumors)
end
