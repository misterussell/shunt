%Shunt.Events.Event{
  id: "liftworks_splice_task1",
  title: "Quiet Draw",

  on_complete: [
    {:knowledge, "splice_task1"},
    {:npc_progression, "liftworks_splice", 1}
  ],

  steps: [
    %{
      id: "ask",
      text: """
      Splice has a second board open now, one you haven't seen — no housing, no
      labels, just a bare stack humming under a rag. "The arch feeds a draw log.
      The draw log feeds a dozen things nobody looks at. I've been reading them."
      They tap the rag flat again. "I need a second set of hands that isn't on
      any roster. Pull for me a few times, through the blind spot, and I'll open
      the cache I've been building off the back of it."
      """,
      choices: [
        %{label: "What am I pulling?", next: "what"},
        %{label: "Not my kind of work", next: "decline"}
      ]
    },
    %{
      id: "what",
      text: """
      "Nothing that trips a flag. Shift logs, transfer manifests — the boring
      exhaust the Authority forgets it's still writing down." Splice slides the
      rag aside for half a second, then covers it again. "You run it clean, it
      never touches your name, and the cache gets fatter for both of us. That's
      the whole arrangement."
      """,
      choices: [
        %{label: "I'll run it", complete: true}
      ]
    },
    %{
      id: "decline",
      text: """
      "Suit yourself." Splice doesn't push. "Offer keeps. The exhaust isn't
      going anywhere — the Authority's too proud to admit it leaks."
      """,
      choices: [
        %{label: "Maybe later", complete: true}
      ]
    }
  ]
}
