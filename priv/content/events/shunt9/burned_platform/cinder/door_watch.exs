%Shunt.Events.Event{
  id: "shunt9_burned_platform_cinder_door_watch",
  title: "Cinder",

  on_complete: [{:npc_progression, "shunt9_burned_platform_cinder", 1}],

  steps: [
    %{
      id: "watching",
      text: """
      Cinder's in the same spot as always, cup in hand, but their eyes
      are on the door today. Fully on it.
      """,
      choices: [
        %{label: "What are you watching for?", next: "watch"},
        %{label: "Leave them to it"}
      ]
    },
    %{
      id: "watch",
      text: """
      A long pause before they answer.

      "The marks." They mean the claw-like gouges in the fused frame.
      "They're older than the fire. I keep thinking there's a pattern.
      There isn't. Or I haven't found it yet." A sip from the cup.
      "The kids say something lives behind it. I told them that was
      stupid." Another sip. "I wasn't sure when I said it."
      """,
      choices: [
        %{label: "What do you think is behind it?", next: "behind"},
        %{label: "You've been here a long time.", next: "long"}
      ]
    },
    %{
      id: "behind",
      text: """
      "Nothing now." Their tone doesn't waver. "But something used to
      pass through here. Whatever it was, it didn't want to be followed."
      They stand, finally. "That's all I've got."
      """,
      choices: [
        %{label: "It's more than most people have.", complete: true}
      ]
    },
    %{
      id: "long",
      text: """
      "Long enough." They don't look away from the door. "I was here
      the night the fire went through. Didn't see how it started.
      Nobody did." A pause that carries weight. "Or nobody's said."
      """,
      choices: [
        %{label: "If you ever want to say it, I'll listen.", complete: true}
      ]
    }
  ]
}
