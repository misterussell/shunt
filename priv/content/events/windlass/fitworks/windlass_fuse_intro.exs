%Shunt.Events.Event{
  id: "windlass_fuse_intro",
  title: "Reading the Room",
  repeatable: false,

  on_complete: [
    {:knowledge, "windlass_fuse_vouched"},
    {:inventory, "tracebreaker", 1}
  ],

  steps: [
    %{
      id: "bench",
      text: """
      Fuse doesn't stop winding the relay in her hands, but her eyes do a slow pass
      over you — inventory, not welcome. "New face on my floor. You're either
      Authority, Syndicate, or lost, and you don't move like the first two." She
      sets the relay down. "The readers over these benches count every hand. You
      want to be useful here, or you want to be counted?"
      """,
      choices: [
        %{label: "Useful. Against the Authority.", next: "vouch"}
      ]
    },
    %{
      id: "vouch",
      text: """
      That earns the first real look she's given you. "Then you'll want the people
      in the back, not me." She palms you something small and cold — a cut deck
      program, Collective work. "Tracebreaker. Quiet as they come; it'll keep a
      sentry off you while you work. Consider it a handshake." She jerks her chin at
      a panel behind the benches. "Drift's through there. I'll pass the word you're
      not a problem. Don't make me a liar."
      """,
      choices: [
        %{label: "Take the deck, take the door", complete: true}
      ]
    }
  ]
}
