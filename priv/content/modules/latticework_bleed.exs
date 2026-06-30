%{
  id: "latticework_bleed",
  name: "Latticework Bleed",
  description:
    "A skim threaded into the Latticework — it bleeds scrip from the people and places around " <>
      "you, a little at a time, and pools it where only you can reach. Quiet until you cash out.",

  # Operator (tier 3) keystone. Needs a real safehouse to run, so the install is gated to a
  # class-2 premises; the heat lands when you move the take, not while it runs (see effect.trace_per).
  cost: %{scrip: 150, cred: 20},
  premises_class_min: 2,
  requirements: [],

  # The flagship income module. rate scrip/hr; cap_hours bounds the reservoir; trace_per is the
  # scrip-per-1-Heat charged on collect. See priv/docs/SHUNT_territory_ladder_v1.md §4.
  effect: %{kind: :income, rate: 5, cap_hours: 12, trace_per: 30}
}
