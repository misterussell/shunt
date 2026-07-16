%Shunt.Events.Event{
  id: "liftworks_nine_iron_intro",
  title: "An Understanding",

  on_complete: [
    {:knowledge, "nine_iron_intro"},
    {:npc_progression, "liftworks_nine_iron", 1}
  ],

  steps: [
    %{
      id: "flagged",
      text: """
      Nine-Iron watches you through the glass of the Watch Office before he waves
      you in, unhurried, the way a man waves in weather. "You're scrolling up my
      watchlist. Faster than most." He doesn't sound alarmed. He sounds like he's
      read the manual and found the margins. "Procedure says I hold you for the
      reader. Procedure and I have an understanding."
      """,
      choices: [
        %{label: "What kind of understanding?", next: "terms"},
        %{label: "Not interested"}
      ]
    },
    %{
      id: "terms",
      text: """
      "You run hot, the Scan Arch remembers it, the Authority reads it, and one
      day you don't come back down the Risers." He leans back. "Or your number
      crosses my desk and I sit on it a while. Heat cools when nobody's watching
      it, and I decide who's watching." A flat pause. "Costs scrip. Everything up
      here costs scrip."
      """,
      choices: [
        %{label: "Fine. We have an understanding", complete: true},
        %{label: "I'll cool it myself", next: "decline"}
      ]
    },
    %{
      id: "decline",
      text: """
      "Sure you will." He's already looking back at the screen. "The offer's on
      the desk when the reader stops liking you. It always stops liking
      somebody."
      """,
      choices: [
        %{label: "Maybe later", complete: true}
      ]
    }
  ]
}
