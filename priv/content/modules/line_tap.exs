%{
  id: "line_tap",
  name: "Line Tap",
  description:
    "A splice spudded into the reclaim conveyor where the sorting line strips the spoiled — it " <>
      "skims a cut of everything the caste pulls off the dead before the wardens weigh it, and " <>
      "banks the take. The more awake the caste runs, the better they cover the skim.",

  # Tier-7 "Relay" keystone (physical). Needs the Galley hideout (class 3) — it runs off the caste's
  # own black-market handling of the reclaim line, so the install is gated to a class-3 premises.
  # Its rate scales with the district `waking` fact: the more lucid and organized the servant caste
  # gets, the more the skim earns (and cover holds) — mirrors signal_tap/bleed_tap.
  cost: %{scrip: 500, cred: 120},
  premises_class_min: 3,
  requirements: [],
  effect: %{
    kind: :income,
    scales_with: %{district: "winnow", fact: :waking},
    rates: %{dulled: 6, stirring: 14, lucid: 28},
    cap_hours: 12,
    trace_per: 25
  }
}
