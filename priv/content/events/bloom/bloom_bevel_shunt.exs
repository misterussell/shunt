%Shunt.Events.Event{
  id: "bloom_bevel_shunt",
  title: "Under the Sheen",
  repeatable: false,
  requirements: [
    {:knows, "bloom_glossed"},
    {:district, "bloom", :season, :>=, :churning}
  ],
  on_complete: [
    {:rumor, "bloom_gloss_shunt"},
    {:knowledge, "bloom_shunt_seen"}
  ],
  steps: [
    %{
      id: "seam",
      text: """
      With the season loud, Bevel talks more than he should. "The seam? Standard.
      Every name that's going up gets the same one." You ask what it does. He
      shrugs, but his hands go still. "Not my end. They send the spec, I fit it, I
      don't ask. It's not cosmetic, I'll tell you that — it goes deep, back of the
      jaw, into the wire that runs a person." He catches himself, laughs it off.
      But you've felt yours now, and you understand: the gloss isn't to make you
      look listed. It's to make you *ready*. Everyone who goes up the throat is
      fitted for it first.
      """,
      choices: [
        %{label: "Touch the seam under your jaw", complete: true}
      ]
    }
  ]
}
