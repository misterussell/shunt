%Shunt.Events.Event{
  id: "windlass_wick_intro",
  title: "Word Gets Down Here",
  repeatable: false,

  on_complete: [
    {:cred, 3}
  ],

  steps: [
    %{
      id: "surface",
      text: """
      He steps out of the dark at the back of the Skim like he's been waiting for
      you to be worth the risk. "Wick. You don't know me — nobody up the coil does,
      that's the whole problem." He keeps his voice under the market-noise. "Word
      got down here you're asking about the list. The purge list. Down here that's
      either the best news in months or a trap, and I've decided to bet you're the
      first one."
      """,
      choices: [
        %{label: "Why surface for me?", next: "stake"}
      ]
    },
    %{
      id: "stake",
      text: """
      "Because my name's on it, and so's everyone I know, and nobody with a permit
      is going to lift a finger for a number in a column." He holds your eye. "You
      keep pulling on this and maybe fewer of us vanish. That's worth coming out of
      the dark for. The Skim hears everything — you need something the floor said and
      thought no one was listening, you come to me." He almost smiles. "Us hollows
      have to be worth something. You're proof we can be."
      """,
      choices: [
        %{label: "I'll come to you", complete: true}
      ]
    }
  ]
}
