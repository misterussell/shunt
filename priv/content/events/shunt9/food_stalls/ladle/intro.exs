%Shunt.Events.Event{
  id: "shunt9_food_stalls_ladle_intro",
  title: "Ladle",

  on_complete: [
    {:npc_progression, "shunt9_food_stalls_ladle", 1}
  ],

  steps: [
    %{
      id: "wok",
      text: """
      The biggest pot on the row belongs to a broad woman working two burners at
      once, sweat-sheened and unbothered, ladling something brown and steaming
      into whatever bowl gets pushed at her. She clocks you over the rising steam.
      "New face. You eat or you move — you're blocking the line either way." Not
      unkind. "Folks call me Ladle. Everybody on this platform's had my stock at
      least once."
      """,
      choices: [
        %{label: "What's in it?", next: "stock"},
        %{label: "Smells good", next: "smells"}
      ]
    },
    %{
      id: "stock",
      text: """
      "Whatever the yard and the relay traps turned up, and you don't ask past
      that." She taps the ladle on the rim, twice. "Rule of the row: a hot bowl
      buys you a seat, and a seat buys you talk. People say things over food they
      wouldn't say sober." A short laugh. "I hear most of this platform before
      the platform does."
      """,
      choices: [
        %{label: "Good to know", complete: true}
      ]
    },
    %{
      id: "smells",
      text: """
      "It always smells good. That's the trick — smells carry further than the
      taste does." Ladle keeps working, but she's sizing you up between stirs.
      "Come back when you're hungry. And you will be. Everybody down here ends up
      hungry, sooner or later."
      """,
      choices: [
        %{label: "I'll be back", complete: true}
      ]
    }
  ]
}
