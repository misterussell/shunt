%{
  id: "skim_crew",
  name: "Skim Crew",
  description:
    "A crew you keep on the floors — embedded in the nightlife and the tables, clipping marks " <>
      "too busy performing wealth to count what they spend. The take flows back through your " <>
      "junction. The hotter the season runs, the more cover they have to work.",

  # Tier-6 "Junction" second income module (social) — the Web-tied generator. Scales with the
  # district `season` fact: a churning/cascade scene = more chaos, more marks, more cover; a
  # gilded (polite, watchful) scene gives them little room. Leans scrip (you pay street operators,
  # not infrastructure) with a hotter trace_per — grifting the rich draws attention.
  cost: %{scrip: 500, cred: 20},
  premises_class_min: 3,
  requirements: [],
  effect: %{
    kind: :income,
    scales_with: %{district: "bloom", fact: :season},
    # TODO: tune the per-level rates — season-scaled, scrip-flavored. Should feel volatile vs the
    # steadier Bleed Tap. Starting guess below.
    rates: %{gilded: 3, churning: 14, cascade: 26},
    cap_hours: 10,
    # TODO: confirm the hotter heat bite reads right in play (lower trace_per = more Heat per scrip
    # collected than the Bleed Tap's 25).
    trace_per: 16
  }
}
