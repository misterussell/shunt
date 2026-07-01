%Shunt.Events.Event{
  id: "bloom_expose",
  title: "Burn It",
  repeatable: false,
  requirements: [
    {:knows, "bloom_truth_substrate"}
  ],
  on_complete: [
    {:knowledge, "bloom_throat_starved"},
    {:knowledge, "bloom_season_cascade"},
    {:heat, 25}
  ],
  steps: [
    %{
      id: "burn",
      text: """
      You don't take the door. You take the throat apart. Everything the Slate's
      back book held, everything under the gloss, everything Pia counted and Renata
      buried — you put it where the whole Bloom reads it at once, and then you jam
      the uptake's core so it can't pull, so nobody goes up while the truth is
      loose. The harvest stops mid-breath. The lights gutter and cool as the throat
      chokes off. The season goes to open war, names falling everywhere at once,
      and the Authority comes down on the district like a hand closing. You're the
      one who broke the Bloom. They will not forget it. Neither will the people you
      just kept out of the wire.
      """,
      choices: [
        %{label: "Let it burn", complete: true}
      ]
    }
  ]
}
