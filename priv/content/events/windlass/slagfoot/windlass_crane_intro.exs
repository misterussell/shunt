%Shunt.Events.Event{
  id: "windlass_crane_intro",
  title: "Freight Moving Again",
  repeatable: false,

  on_complete: [
    {:scrip, 10}
  ],

  steps: [
    %{
      id: "yard",
      text: """
      He's got a hand-truck stacked before you've reached him, working the revived
      yard like he never left — because he didn't, he just went quiet when the coil
      did. "You're the one who woke the engine," Crane says, not looking up from his
      load. "Whole yard's back on your account. Traders like me don't work a dead
      Landing." He slaps a crate. "So here's my thanks and my pitch, same breath."
      """,
      choices: [
        %{label: "Go on", next: "cut"}
      ]
    },
    %{
      id: "cut",
      text: """
      "I move things up the coil that don't want a manifest. Now the freight's
      climbing, I can move them for you too — for a cut, and quieter than the
      market." He finally looks at you and grins. "Consider this first one on me."
      He palms you a few notes off his own run. "Freight's the bloodstream of this
      place. You started it pumping. People up the coil are going to notice the
      Windlass has a pulse again — and start wondering who gave it one."
      """,
      choices: [
        %{label: "Take the cut", complete: true}
      ]
    }
  ]
}
