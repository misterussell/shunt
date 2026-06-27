%Shunt.Events.Event{
  id: "shunt9_bazaar_nickel_chits",
  title: "A New Chit",

  on_complete: [
    {:npc_progression, "shunt9_bazaar_nickel", 1},
    {:rumor, "protection_chits"}
  ],

  steps: [
    %{
      id: "show",
      text: """
      Nickel palms a chit you don't recognize — wrong stamp, wrong weight. "See
      this? Not a debt marker. Not a trade voucher. This is new." He keeps his
      voice flat and low. "Hand one to the right collector, your stall stays
      unbothered a week. Don't carry them..." He lets it hang. "Stalls that won't
      play find their pitch gone by morning. Their supply dried up. Their luck
      just bad."
      """,
      choices: [
        %{label: "Who's collecting?", next: "who"},
        %{label: "Sounds like protection", next: "protection"}
      ]
    },
    %{
      id: "who",
      text: """
      "If I knew, I'd be charging for it." For once the smile's gone. "Whoever
      it is doesn't show a face. Just chits, and the stalls too scared not to
      carry them. Even I'm moving a few — a man likes to keep his gap." He slides
      the strange chit back out of sight. "You're the type that pulls threads.
      Pull this one careful."
      """,
      choices: [
        %{label: "I'll look into it", complete: true}
      ]
    },
    %{
      id: "protection",
      text: """
      "Call it what you like. The stalls call it the price of standing here."
      Nickel shrugs, but it's a tight shrug. "Somebody claimed this platform
      quiet, and now everybody pays rent on air. I just move the paper. You want
      to know who prints it, that's above my cut." He nods you off. "Careful who
      you ask."
      """,
      choices: [
        %{label: "Noted", complete: true}
      ]
    }
  ]
}
