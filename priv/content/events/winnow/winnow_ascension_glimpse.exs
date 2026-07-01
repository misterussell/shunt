%Shunt.Events.Event{
  id: "winnow_ascension_glimpse",
  title: "The First Honest Look",
  repeatable: false,
  requirements: [
    {:knows, "winnow_shunt_complete"}
  ],
  on_complete: [
    {:knowledge, "winnow_ascended"}
  ],
  steps: [
    %{
      id: "look",
      text: """
      You walk the channel up past where the Authority's reach ends, and the Winnow opens
      out beneath you, and for the first time someone from below sees the Spire for what it
      is: not a summit but a gut, tier on tier of it climbing away, every district you
      crawled through built to feed this — and above even the Authority, patient and vast
      and writing the number, the thing that eats what the throat sends up and decides,
      season by season, how choosy the wire gets to be. You feel your shunt reach for it and
      you hold, on the edge of it, still yourself. The way on is right there. It does not
      open. Not yet, not for you, not tonight. But you know now what nobody below you knows:
      that the climb everyone's killing themselves to make ends in a mouth, and the Authority
      isn't the one doing the eating. You came up spoiled, or you came up burning. Either
      way you're the first thing to look the top in the eye and not be swallowed. You take
      the look back down with you. Somebody has to carry it.
      """,
      choices: [
        %{label: "Carry it", complete: true}
      ]
    }
  ]
}
