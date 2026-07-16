%Shunt.Events.Event{
  id: "shunt9_rook_task1",
  title: "A Matter of Paper",

  on_complete: [
    {:knowledge, "rook_task1"},
    {:npc_progression, "shunt9_rook", 1}
  ],

  steps: [
    %{
      id: "ask",
      text: """
      Rook doesn't look up from the ledger when you reach the desk. A sealed
      marker sits between his hands — folded paper, no name on the outside.
      "Somebody two stalls down is deep in the book, and he's the sort who pays a
      stranger faster than he pays me." He finally lifts his eyes. "Carry this to
      him. Come back with what he hands you, all of it. That's the whole test."
      """,
      choices: [
        %{label: "What's on the paper?", next: "what"},
        %{label: "I don't run errands", next: "decline"}
      ]
    },
    %{
      id: "what",
      text: """
      "A number. His number — how deep he is, and by when." Rook keeps his thumb
      flat on the marker. "Men have skimmed a marker like this and thought I
      wouldn't notice the shortfall. I always notice the shortfall." He slides it
      across. "Run it straight and you stop being a stranger to me. That opens a
      quieter channel for whatever you need moved."
      """,
      choices: [
        %{label: "Consider it run", complete: true}
      ]
    },
    %{
      id: "decline",
      text: """
      "Then we stay where we are." Rook sets the marker down without a flicker.
      "The offer keeps. Paper doesn't spoil, and neither does a debt."
      """,
      choices: [
        %{label: "Maybe later", complete: true}
      ]
    }
  ]
}
