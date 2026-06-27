defmodule Shunt.Web.RumorConnection do
  @moduledoc false

  alias Shunt.Content

  # NOTE: `partial_threshold`, `partial_event_id`, and `failure_event_id` are currently unused —
  # the v2 board resonates on exact cluster match only, and the old `Web.resolve_theory/2` that
  # consumed them was removed. They're kept on purpose as scaffolding: partial matching will
  # likely surface later. Don't drop these (or the supplier_conspiracy partial/failure events and
  # the authority_involvement rumor) as dead code.
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
