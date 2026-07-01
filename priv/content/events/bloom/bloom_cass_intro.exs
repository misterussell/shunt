%Shunt.Events.Event{
  id: "bloom_cass_intro",
  title: "The Regular",
  repeatable: false,
  requirements: [],
  on_complete: [
    {:contact, "bloom_cass"},
    {:rumor, "bloom_vanished_after"},
    {:knowledge, "bloom_den_vouched"}
  ],
  steps: [
    %{
      id: "bar",
      text: """
      Cass pours before you ask, reads you in the time it takes to set the glass
      down, and decides she likes you enough to talk. She talks about a regular —
      listed last season, bought the room a round the night before she went up,
      glowing with it. Went up the next morning. "Not a word since," Cass says,
      wiping the bar that doesn't need it. "You'd think one of them would write."
      She tips her head at the red-lit door behind her. "Go on back if you want.
      Tell them I sent you."
      """,
      choices: [
        %{label: "Take the drink", complete: true}
      ]
    }
  ]
}
