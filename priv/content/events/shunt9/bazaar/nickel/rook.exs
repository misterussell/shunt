%Shunt.Events.Event{
  id: "shunt9_bazaar_nickel_rook",
  title: "Vouched",

  on_complete: [
    {:npc_progression, "shunt9_bazaar_nickel", 1},
    {:knowledge, "rook"}
  ],

  steps: [
    %{
      id: "weigh",
      text: """
      Nickel watches you a beat longer than usual before the chit starts moving
      across his knuckles again. "You've run enough small stuff past me clean. I
      know where most of it came from, and you didn't lie about the parts that
      mattered." The chit stops. "That buys you a name. Rook. Keeps a desk back in
      the corner where the lamps don't reach. Fences the heavy things I won't
      touch — hot data, gear with a serial somebody's still looking for."
      """,
      choices: [
        %{label: "What's the catch?", next: "catch"},
        %{label: "Why tell me?", next: "why"}
      ]
    },
    %{
      id: "catch",
      text: """
      "Rook pays better and asks harder. Where'd you get it, who saw you lift it,
      who's going to come asking after." The smile is thin. "I don't ask, so my
      cut's thin. Rook asks, so Rook's cut's worth it — long as your answers hold."
      He tips his head toward the back of the bazaar. "Tell the desk Nickel sent
      you. That's the whole of the favor. Spend it well."
      """,
      choices: [
        %{label: "I'll find the desk", complete: true}
      ]
    },
    %{
      id: "why",
      text: """
      "Because you keep coming back with warm goods, and sooner or later something
      lands in your pocket too big for my gap." Nickel shrugs. "Better you take it
      to Rook than to somebody who doesn't know your face. A man likes his regulars
      to land soft." The chit vanishes. "Tell the desk Nickel sent you. Rook'll
      know the name."
      """,
      choices: [
        %{label: "Appreciated", complete: true}
      ]
    }
  ]
}
