%Shunt.Events.Event{
  id: "shunt9_power_relay_coil_intro",
  title: "Coil",

  on_complete: [{:npc_progression, "shunt9_power_relay_coil", 1}],

  steps: [
    %{
      id: "notice",
      text: """
      Someone's wedged half inside a transformer housing, doing
      something to the secondary bus by feel. The hum of the relay
      is different here — lower, like the room is holding its breath.
      """,
      choices: [
        %{label: "Wait for them to surface", next: "surface"},
        %{label: "Come back later"}
      ]
    },
    %{
      id: "surface",
      text: """
      They back out, tools in hand, and size you up without any alarm.
      They've been found in places they shouldn't be before.

      "You're not KA." Not a question. "Relay's restricted — officially.
      I'm why it still runs — unofficially. Name's Coil." A nod at the
      transformers. "Don't touch anything."
      """,
      choices: [
        %{label: "Who knows you're here?", next: "who"},
        %{label: "I'm not here to cause problems.", next: "problems"}
      ]
    },
    %{
      id: "who",
      text: """
      "People who need the power to stay on." A dry smile. "Which is
      everyone. So: nobody officially, everyone practically." They
      wipe their hands on a rag. "Keep it that way and we'll get
      along fine."
      """,
      choices: [
        %{label: "Understood.", complete: true}
      ]
    },
    %{
      id: "problems",
      text: """
      "Good. I've got enough of those already." A glance at the
      monitoring panel on the far wall — quick, then away. "Come
      back if you need something. I'm always here."
      """,
      choices: [
        %{label: "I'll remember that.", complete: true}
      ]
    }
  ]
}
