%Shunt.Events.Event{
  id: "shunt9_power_relay_coil_bad_tap",
  title: "Coil",

  on_complete: [{:npc_progression, "shunt9_power_relay_coil", 1}],

  steps: [
    %{
      id: "tense",
      text: """
      Coil's monitoring panel is lit harder than usual and they look
      like they haven't slept. They wave you over before you can say
      anything.

      "You know the duct junction on the east wall — the one that
      runs back toward the maintenance tunnel?"
      """,
      choices: [
        %{label: "I've seen it.", next: "seen"},
        %{label: "What about it?", next: "seen"}
      ]
    },
    %{
      id: "seen",
      text: """
      "Someone's tapped into the secondary feed there. Three weeks
      ago, nothing. Now they're pulling enough current to run a full
      workshop." They turn a handwritten log toward you. "I don't
      know who. I don't know what for. But that draw doesn't stay
      quiet — KA will notice the bleed on their end eventually."

      A direct look. "I need someone to go see what's running back
      there. Someone who doesn't show up on a KA access log."
      """,
      choices: [
        %{label: "I'll go look.", next: "go"},
        %{label: "That's not my kind of work.", next: "no"}
      ]
    },
    %{
      id: "go",
      text: """
      "Don't engage whoever it is. Just find out what they're running
      and come back." They write something on a scrap of paper and
      hand it over. "That's the junction. You'll smell the heat
      before you see it."
      """,
      choices: [
        %{label: "I'll be back.", complete: true}
      ]
    },
    %{
      id: "no",
      text: """
      "Fair." Coil folds the log away. "But if the KA come knocking
      on this relay, none of us have power. Think about that." Back
      to the panel. "Door's open if you change your mind."
      """,
      choices: [
        %{label: "I'll think about it.", complete: true}
      ]
    }
  ]
}
