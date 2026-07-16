%Shunt.Events.Event{
  id: "liftworks_nine_iron_task1",
  title: "Behind the Cabinet",

  on_complete: [
    {:knowledge, "nine_iron_task1"},
    {:npc_progression, "liftworks_nine_iron", 1}
  ],

  steps: [
    %{
      id: "ask",
      text: """
      Nine-Iron slides a slate across the desk without turning it toward you.
      "Somebody upstairs filed on you. Real paper, not a reader flag — the kind
      that sticks." He taps it once. "I can process it. Or it can fall behind the
      cabinet, where a lot of paper's already fallen." He finally looks at you.
      "You've kept quiet about our arrangement. Quiet's worth something to me."
      """,
      choices: [
        %{label: "Let it fall", next: "terms"},
        %{label: "Why do this?", next: "why"}
      ]
    },
    %{
      id: "terms",
      text: """
      "It doesn't get shredded — shredded shows. It gets misfiled. Lost. The
      Authority trusts its own records too much to go looking behind the
      cabinet." A thin, procedural satisfaction crosses him. "From here I don't
      just cool your number. I lose the report before it's ever a number. Cheaper
      for you, quieter for me. Keep being quiet."
      """,
      choices: [
        %{label: "Understood", complete: true}
      ]
    },
    %{
      id: "why",
      text: """
      "Because a man who processes everything by the book gets nothing but the
      book." He shrugs. "Twenty years on this checkpoint, you learn where it
      leaks. You're a leak I control. That's worth more to me than a leak I
      report."
      """,
      choices: [
        %{label: "I can be that", next: "terms"}
      ]
    }
  ]
}
