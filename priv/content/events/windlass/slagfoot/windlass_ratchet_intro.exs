%Shunt.Events.Event{
  id: "windlass_ratchet_intro",
  title: "Somebody Killed It",
  repeatable: false,

  on_complete: [
    {:rumor, "windlass_stalled_on_purpose"}
  ],

  steps: [
    %{
      id: "floor",
      text: """
      Ratchet doesn't stop working while he talks, and what he's working on is
      nothing — a cold furnace, a rag, thirty years of habit. "You're the one
      Hopper sent up. Good. Somebody should hear it who isn't on the Authority's
      payroll." He finally looks at you. "That engine didn't wear out. I've had
      my hands in it since before you were born. It was killed."
      """,
      choices: [
        %{label: "How do you know?", next: "governor"}
      ]
    },
    %{
      id: "governor",
      text: """
      "Because I know what a worn governor looks like and I know what a pulled one
      looks like, and that's a pulled one. Somebody reached in, took the piece that
      lets the drive spin up, bolted the plate back, and signed a notice calling it
      failure." He wipes his hands. "You want to know who and why, you'll have to
      go higher than me. But if you want to make them liars — get the engine
      running again. Truth climbs faster than any freight."
      """,
      choices: [
        %{label: "I'll look into it", complete: true}
      ]
    }
  ]
}
