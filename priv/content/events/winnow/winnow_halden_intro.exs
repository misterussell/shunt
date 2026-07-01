%Shunt.Events.Event{
  id: "winnow_halden_intro",
  title: "The Hand, Not the Head",
  repeatable: false,
  requirements: [],
  on_complete: [
    {:contact, "winnow_halden"}
  ],
  steps: [
    %{
      id: "catwalk",
      text: """
      Halden runs the whole Winnow and greets you like a problem he'll have to file.
      "New load doesn't talk to me. Sorted load doesn't talk to me. So which are you." He
      doesn't wait. "Doesn't matter. You'll make the number or you'll be the number. That's
      not cruelty, it's arithmetic, and I don't own the arithmetic any more than you do."
      For half a second his eyes go to the far end of the Gantry — to the sealed door — and
      come back fast, like a man who touched a hot line. "I keep this floor moving. That's
      the top of my authority and the bottom of somebody else's. Do your work and we'll
      never speak again." It sounds like a threat. It's closer to a warning, and not about
      you.
      """,
      choices: [
        %{label: "Say nothing", complete: true}
      ]
    }
  ]
}
