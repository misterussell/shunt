%Shunt.Web.RumorConnection{
  id: "winnow_tier_above",
  # The Spire's opening case: the Authority isn't the top. Five rumors come off the caste (the
  # kept-whole staff, the climbing spoiled count, the scared wardens, the sealed door, what the wire
  # leaves of the ascended); the sixth (winnow_directive) is locked behind winnow_line_ice, so a full
  # crack forces a Ghostwork run for the orders themselves. Success grants winnow_tier_above — which
  # opens the sealed door on the Gantry (the Vestibule) and unlocks the finale ICE beyond it.
  rumors: [
    "winnow_directive",
    "winnow_wardens_afraid",
    "winnow_spoiled_count",
    "winnow_kept_whole",
    "winnow_the_door",
    "winnow_no_ascended_return"
  ],
  partial_threshold: 4,
  success_event_id: "winnow_case_success",
  partial_event_id: "winnow_case_partial",
  failure_event_id: "winnow_case_failure"
}
