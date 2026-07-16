%Shunt.Events.Event{
  id: "crossgate_mother_graft_intro",
  title: "Rough Draft",

  on_complete: [
    {:knowledge, "mother_graft_intro"},
    {:npc_progression, "crossgate_mother_graft", 1}
  ],

  steps: [
    %{
      id: "meet",
      text: """
      She doesn't stop working when you come in — a wire threaded under someone's
      forearm skin, drawn tight, tied off. Only then does she look up. "You've got
      good salvage on you. Cracked plate, sleeve of dead weave, whatever the meat
      wouldn't keep." She wipes her hands. "Most fitters throw that out. I don't.
      Flesh is a first pass. The good bits get reused."
      """,
      choices: [
        %{label: "You buy scraps?", next: "terms"},
        %{label: "Not selling", next: "leave"}
      ]
    },
    %{
      id: "terms",
      text: """
      "I buy what nobody else will touch. Bone plate, subdermal offcuts, anything
      the Fleshless can re-seat into somebody who needs it more." She names a rate,
      flat and unhurried. "It moves warm at first — a little heat on the exchange,
      until the Den learns your face. Bring it clean and the number gets better.
      That's the whole relationship."
      """,
      choices: [
        %{label: "I'll start bringing it", complete: true}
      ]
    },
    %{
      id: "leave",
      text: """
      "Then you're carrying stock and calling it garbage." She's already back over
      the arm, tying the next knot. "Door's open when you change your mind. Parts
      don't get less useful sitting in your pocket."
      """,
      choices: [
        %{label: "Maybe later"}
      ]
    }
  ]
}
