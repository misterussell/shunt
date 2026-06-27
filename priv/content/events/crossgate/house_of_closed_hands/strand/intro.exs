%Shunt.Events.Event{
  id: "crossgate_house_strand_intro",
  title: "Strand",

  on_complete: [{:npc_progression, "crossgate_house_strand", 1}],

  steps: [
    %{
      id: "enter",
      text: """
      The room is quiet in the way that rooms with money in them
      tend to be quiet. A person sits at the far end of a plain
      table — no display of wealth, no visible weapons, no
      entourage. They were expecting you.

      "Ratchet's runner." Not a question. They read the slip you
      were given, fold it once, set it down. "The short count.
      We're aware of it." A measured look. "We've been watching
      the runner who's been using the Spine to skip the gate.
      What we don't know yet is who they're moving product for."
      """,
      choices: [
        %{label: "What do you need from me?", next: "need"},
        %{label: "I'm just delivering a message.", next: "message"}
      ]
    },
    %{
      id: "need",
      text: """
      "Nothing yet. You've been useful by being here — it tells
      me Ratchet trusts you, which is not easily earned." They
      stand. "My name is Strand. You'll hear it again if you
      continue to be worth hearing from."

      The meeting is over as clearly as if a door had closed.
      """,
      choices: [
        %{label: "Understood.", complete: true}
      ]
    },
    %{
      id: "message",
      text: """
      "The message was the carrier." A small pause that carries
      weight. "Ratchet doesn't send people he hasn't read. You
      passed his read." They sit back. "My name is Strand. Come
      back when you have something worth bringing me."
      """,
      choices: [
        %{label: "I will.", complete: true}
      ]
    }
  ]
}
