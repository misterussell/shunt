%{
  id: "bleed_tap",
  name: "Bleed Tap",
  description:
    "A line spliced into the runoff pooling in your junction — it skims the Spire's bleed-power " <>
      "the Bloom runs on and banks the take. The harder the throat pulls, the more spills past " <>
      "you to skim.",

  # Tier-6 "Junction" keystone (physical). Needs the Junction hideout (class 3) — it taps straight
  # into the Spire's exhaust bleed, so the install is gated to a class-3 premises. Its rate scales
  # with the district `draw` fact: chasing income literally speeds the harvest, and the Expose
  # ending (draw -> :slack) craters it.
  cost: %{scrip: 400, cred: 80},
  premises_class_min: 3,
  requirements: [],
  effect: %{
    kind: :income,
    scales_with: %{district: "bloom", fact: :draw},
    # TODO: tune the per-level rates — draw-scaled, cred-tier district, should out-earn signal_tap
    # at :gorging. Starting guess below; balance against Skim Crew so neither dominates.
    rates: %{slack: 5, drawing: 12, gorging: 24},
    cap_hours: 12,
    trace_per: 25
  }
}
