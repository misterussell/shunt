%Shunt.Events.Event{
  id: "shunt9_tally_intro",
  title: "Open Account",

  on_complete: [
    {:knowledge, "tally_intro"},
    {:npc_progression, "shunt9_tally", 1}
  ],

  steps: [
    %{
      id: "meet",
      text: """
      Tally doesn't sell anything you can hold. Her stall is a plank, a stool,
      and a slate she never stops thumbing — and she's got your name on it before
      you've said it. "New face, old story. Everybody who works this platform runs
      a tab with the Syndicate whether they signed for it or not." The grin's
      easy. "I'm the one who keeps the number. Friendly number, long as you're
      friendly back."
      """,
      choices: [
        %{label: "What number?", next: "number"},
        %{label: "I don't owe anybody", next: "owe"},
        %{label: "Not interested"}
      ]
    },
    %{
      id: "number",
      text: """
      "Stall fees, protection you never asked for, the cut on every deal that
      closes where I can hear it — the Closed Hands don't miss much, and I hear
      all of it." She taps the slate. "Here's what nobody tells you: a debt on the
      books is just a debt somebody hasn't moved around yet. Bring me a cred — a
      marker, a favor owed you, don't care whose — and I'll square you with the
      Syndicate and skim you back some scrip off the top. That's the trade."
      """,
      choices: [
        %{label: "That's a start", complete: true}
      ]
    },
    %{
      id: "owe",
      text: """
      "Everybody says that. Everybody's wrong." She isn't offended; she's amused.
      "You breathe on this platform, the Syndicate's got a line on you. Only
      difference between me and them is I'll tell you the number to your face
      instead of letting it grow quiet in the dark." A shrug. "Come back when
      you'd rather have me holding the pen than someone who won't smile while
      they do it."
      """,
      choices: [
        %{label: "Fair enough", complete: true}
      ]
    }
  ]
}
