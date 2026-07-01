%Shunt.Events.Event{
  id: "bloom_soot_intro",
  title: "Behind the Walls",
  repeatable: false,
  requirements: [],
  on_complete: [
    {:contact, "bloom_soot"}
  ],
  steps: [
    %{
      id: "spine",
      text: """
      Soot doesn't look up from the damper he's fighting. "You want the pretty
      side, it's back the way you came." When you don't leave, he grunts, almost
      approving. "Whole Bloom runs on what I keep breathing back here. Intake's
      choked half to death, manifold's seized, and nobody up top'll pay for the
      parts — they just want the lights to stay on." He wipes his hands on cloth
      that makes them dirtier. "You do duct-work, there's always work. And you see
      things, back here. More than the ones with names ever do."
      """,
      choices: [
        %{label: "Say you do duct-work", complete: true}
      ]
    }
  ]
}
