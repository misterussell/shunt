defmodule Shunt.Web.RumorConnection do
  @moduledoc false

  alias Shunt.Content

  # NOTE: `failure_event_id` is currently unused — the v2 board has no failure path yet (the old
  # `Web.resolve_theory/2` that consumed it was removed). It's kept on purpose as scaffolding,
  # along with the connections' failure events, since a failure path will likely surface later;
  # don't drop them as dead code. (`partial_threshold` and `partial_event_id` are now live: the
  # warmth/leads strip reads the threshold, and [ FOLLOW LEAD ] starts the partial event — which
  # for supplier_conspiracy in turn awards the authority_involvement rumor.)
  # TODO: [data-model] Add authored, shown-up-front heat costs for acting on a case:
  #   :lead_heat (following a lead / partial_event) and :crack_heat (cracking / success_event).
  # Add both to defstruct and @enforce_keys (ints), then populate every file in
  # priv/content/rumor_connections/*.exs (all 7) with values — enforce means nothing loads until
  # they're all set. Assert the fields load in test/shunt/web/rumor_connection_test.exs.
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
