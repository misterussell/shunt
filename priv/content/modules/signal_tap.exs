%{
  id: "signal_tap",
  name: "Signal Tap",
  description:
    "A hard line spliced off the district grid and threaded into your floor — it skims the " <>
      "signal traffic flowing past the Loft and pools the take. The more of the grid runs open, " <>
      "the more moves past you to skim.",

  # Node (tier 5) keystone. Needs the Winder's Loft (class 3) to run — it taps straight into the
  # Fitworks grid, so the install is gated to a class-3 premises. Its rate is not fixed: it scales
  # with the district `grid` fact, so cracking the Windlass open literally raises what it earns.
  cost: %{scrip: 300, cred: 40},
  premises_class_min: 3,
  requirements: [],

  # An income module whose rate is derived from the Windlass grid fact instead of a static value
  # (Shunt.Territory resolves `scales_with` per player). cap_hours bounds the reservoir; trace_per
  # is the scrip-per-1-Heat charged on collect. See priv/docs/SHUNT_territory_ladder_v1.md §4.
  effect: %{
    kind: :income,
    scales_with: %{district: "windlass", fact: :grid},
    rates: %{clamped: 4, contested: 8, open: 16},
    cap_hours: 12,
    trace_per: 25
  }
}
