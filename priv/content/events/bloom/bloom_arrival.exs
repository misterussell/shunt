%Shunt.Events.Event{
  id: "bloom_arrival",
  title: "Into the Light",
  repeatable: false,
  requirements: [],
  on_complete: [
    {:knowledge, "bloom_arrived"}
  ],
  steps: [
    %{
      id: "rim",
      text: """
      The anchor lift lets you off into more light than the whole Windlass had,
      and none of it paid for — the Spire's runoff, pooled and dressed up as
      wealth. Every face on the Rimwalk is performing a fortune it's still
      climbing toward, and the throat glows over all of it like a promise. This
      is the last ground before the Spire, and everyone here is starving for the
      way up. You'll learn what that costs later. For now you just walk in.
      """,
      choices: [
        %{label: "Walk in", complete: true}
      ]
    }
  ]
}
