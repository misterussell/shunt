%Shunt.Events.Event{
  id: "windlass_sabotage_failure",
  title: "Wrong Threads",
  repeatable: true,

  on_complete: [
    {:heat, 6}
  ],

  steps: [
    %{
      id: "noise",
      text: """
      You force the connections and they don't hold — a shape that looks like an
      answer until you lean on it, and then it's just noise wearing the shape of
      one. Worse, you've been asking the wrong questions loudly in a district where
      the walls report. Somewhere in the Ascent Office a clerk makes a note. Pull the
      threads apart and start again, quieter this time, before the note becomes a
      name.
      """,
      choices: [
        %{label: "Back to the board", complete: true}
      ]
    }
  ]
}
