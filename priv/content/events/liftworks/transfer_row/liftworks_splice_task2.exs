%Shunt.Events.Event{
  id: "liftworks_splice_task2",
  title: "The Whole Feed",

  on_complete: [
    {:knowledge, "splice_task2"},
    {:npc_progression, "liftworks_splice", 1}
  ],

  steps: [
    %{
      id: "open",
      text: """
      The rag is gone. The bare stack is wired into three others now, and Splice
      is watching lines of draw scroll past like they're reading weather. "You
      kept it quiet. Longer than most would've." They don't look away from the
      feed. "The Collective doesn't hand this out. But you've been careful with
      it, so I'm going to stop metering you."
      """,
      choices: [
        %{label: "What changes?", next: "change"},
        %{label: "Why trust me with it?", next: "why"}
      ]
    },
    %{
      id: "change",
      text: """
      "You get the feed straight — no cache in between, no waiting on me to
      surface it." Splice finally turns. "Whatever's moving through the blind
      spot, you'll have it before the reader upstairs does. Use it like it's
      borrowed, because it is."
      """,
      choices: [
        %{label: "Understood", complete: true}
      ]
    },
    %{
      id: "why",
      text: """
      "Because the Latticework only holds if somebody outside it stays useful,
      and everybody inside it is already spent." A thin smile. "You're not on a
      roster. That's worth more than loyalty around here."
      """,
      choices: [
        %{label: "I'll keep it that way", complete: true}
      ]
    }
  ]
}
