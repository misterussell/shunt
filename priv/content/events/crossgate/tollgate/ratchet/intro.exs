%Shunt.Events.Event{
  id: "crossgate_tollgate_ratchet_intro",
  title: "Ratchet",

  on_complete: [{:npc_progression, "crossgate_tollgate_ratchet", 1}],

  steps: [
    %{
      id: "stopped",
      text: """
      A broad figure leans against the reinforced booth, arms crossed,
      watching the tunnel entrance with the patience of someone who
      has been doing this a long time. They hold up a hand before you
      get past the first marker.

      "New face. That means you haven't paid yet." A look at you, not
      hostile, not friendly. "Toll's ten scrip to operate in The
      Crossgate. No exceptions. Name's Ratchet."
      """,
      choices: [
        %{label: "Pay the toll.", next: "pay"},
        %{label: "On what authority?", next: "authority"}
      ]
    },
    %{
      id: "pay",
      text: """
      Ratchet pockets the scrip without counting it. They already know
      it's right.

      "You'll pay each time you come through until the Syndicate
      decides you're regular enough for a monthly rate. Keep your
      head down, don't move product that hasn't been cleared, and
      we won't have a problem."
      """,
      choices: [
        %{label: "Understood.", complete: true}
      ]
    },
    %{
      id: "authority",
      text: """
      Ratchet doesn't shift their posture. "The Syndicate of Closed
      Hands. They own the infrastructure you're standing in. The
      power keeping those lights on. The arrangement keeping the KA
      out." A pause. "Ten scrip."
      """,
      choices: [
        %{label: "Pay the toll.", next: "pay"},
        %{label: "I'll come back another time.", next: "leave"}
      ]
    },
    %{
      id: "leave",
      text: """
      "Door's that way." Ratchet gestures toward the tunnel without
      looking. "It'll still be ten when you come back."
      """,
      choices: [
        %{label: "Walk back out."}
      ]
    }
  ]
}
