defmodule Shunt.Web.RumorConnection do
  @moduledoc false

  alias Shunt.Content

  @enforce_keys [
    :id,
    :rumors,
    :partial_threshold,
    :success_event_id,
    :partial_event_id,
    :failure_event_id
  ]
  defstruct [
    :id,
    :rumors,
    :partial_threshold,
    :success_event_id,
    :partial_event_id,
    :failure_event_id
  ]

  def fetch!(id), do: Content.fetch!(:rumor_connections, id)

  def all, do: Content.all(:rumor_connections)
end
