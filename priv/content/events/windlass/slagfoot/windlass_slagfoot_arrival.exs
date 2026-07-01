%Shunt.Events.Event{
  id: "windlass_slagfoot_arrival",
  title: "Bottom of the Coil",
  repeatable: false,

  on_complete: [
    {:knowledge, "windlass_arrived"}
  ],

  steps: [
    %{
      id: "landing",
      text: """
      Cinder watches you step off the transit line and reads you the way
      dockhands read cargo. "Grayline," she says, not a question. "They all come
      up through here eventually. Welcome to the Windlass." She tips her head at
      the great coil climbing out of sight overhead. "City wound up a hauling
      engine. Slagworks at the bottom, then the fitters, then the market, then
      the clean people at the top who'll never once look down at us. You want up,
      you climb the stair like everyone else."
      """,
      choices: [
        %{label: "Why are the cranes cold?", next: "stall"}
      ]
    },
    %{
      id: "stall",
      text: """
      "Engine stalled. Weeks back." Cinder's jaw sets. "No freight climbing means
      no work down here and no parts up there, and the Authority stood up on their
      readers and called it wear-and-tear." She spits. "Thirty-year engine doesn't
      just quit. But nobody asked me. Talk to Ratchet in the Slagworks if you want
      the version from someone who actually knows the machine. And watch the
      readers on the stair — up here, the grid counts you every step."
      """,
      choices: [
        %{label: "Start climbing", complete: true}
      ]
    }
  ]
}
