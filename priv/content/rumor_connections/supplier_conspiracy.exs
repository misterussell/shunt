%Shunt.Web.RumorConnection{
  # TODO: fill in real content once the RumorConnection struct and outcome events exist.
  # partial_threshold: integer — how many of :rumors must overlap for a partial outcome.
  # success/partial/failure event ids must point to authored events in priv/content/events/.
  id: "supplier_conspiracy",
  rumors: ["juno_supplier", "missing_shipments", "vex_debts"],
  partial_threshold: 2,
  success_event_id: "supplier_conspiracy_success",
  partial_event_id: "supplier_conspiracy_partial",
  failure_event_id: "supplier_conspiracy_failure"
}
