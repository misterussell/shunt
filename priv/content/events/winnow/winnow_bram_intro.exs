%Shunt.Events.Event{
  id: "winnow_bram_intro",
  title: "Pulled to the Belt",
  repeatable: false,
  requirements: [],
  on_complete: [
    {:contact, "winnow_bram"}
  ],
  steps: [
    %{
      id: "line",
      text: """
      He's stacking listed tags into a tin, one for each name walked up to the gate today,
      and the tin is nearly full. "You're new, so you don't know me — that's because I don't
      work down here. I keep the good side of the Floor, the clean belt, the ones going up
      proper." He shakes the tin. It rattles like teeth. "When the number goes to culling
      they don't have enough wardens to walk the count, so they pull keepers to do it. Me.
      I walk them to the gate. I'm good at it, is the thing. I keep them calm." He can't
      quite look at you. "You want to survive the Winnow, be useful. That's the whole trick.
      Nobody tells you what they'll make you useful *for*."
      """,
      choices: [
        %{label: "Take the measure of him", complete: true}
      ]
    }
  ]
}
