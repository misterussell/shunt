defmodule Shunt.Web.RumorConnection do
  @moduledoc false

  alias Shunt.Content

  # NOTE: `failure_event_id` is currently unused — the v2 board has no failure path yet (the old
  # `Web.resolve_theory/2` that consumed it was removed). It's kept on purpose as scaffolding,
  # along with the connections' failure events, since a failure path will likely surface later;
  # don't drop them as dead code. (`partial_threshold` and `partial_event_id` are now live: the
  # warmth/leads strip reads the threshold, and [ FOLLOW LEAD ] starts the partial event — which
  # for supplier_conspiracy in turn awards the authority_involvement rumor.)
  # `lead_heat`/`crack_heat` are the authored, shown-up-front heat the player takes on for acting on
  # a case: following a lead (partial_event) vs cracking it outright (success_event). Probing the
  # hidden network exposes you — cracking is the bigger commitment, so it costs more heat.
  @enforce_keys [
    :id,
    :rumors,
    :partial_threshold,
    :success_event_id,
    :partial_event_id,
    :failure_event_id,
    :lead_heat,
    :crack_heat
  ]
  defstruct [
    :id,
    :rumors,
    :partial_threshold,
    :success_event_id,
    :partial_event_id,
    :failure_event_id,
    :lead_heat,
    :crack_heat
  ]

  def fetch!(id), do: Content.fetch!(:rumor_connections, id)

  def fetch(id), do: Content.fetch(:rumor_connections, id)

  def all, do: Content.all(:rumor_connections)
end
