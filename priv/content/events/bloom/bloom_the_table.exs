%Shunt.Events.Event{
  id: "bloom_the_table",
  title: "A Seat at the Spread",
  repeatable: false,
  requirements: [],
  on_complete: [
    {:knowledge, "bloom_reserve_invited"}
  ],
  steps: [
    %{
      id: "table",
      text: """
      The Spread runs on talk more than food, and you're good at talk. You spend
      a course listening, a course saying the right small things, and by the time
      the plates clear someone two seats down has decided you're worth a private
      word. A card comes down the table without a face attached to it: the booths,
      the Reserve, whenever you like. In the Bloom an invitation is the whole game,
      and you've just been dealt into it.
      """,
      choices: [
        %{label: "Pocket the card", complete: true}
      ]
    }
  ]
}
