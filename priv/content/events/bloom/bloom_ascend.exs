%Shunt.Events.Event{
  id: "bloom_ascend",
  title: "Go Up",
  repeatable: false,
  requirements: [
    {:knows, "bloom_truth_substrate"}
  ],
  on_complete: [
    {:knowledge, "bloom_ascended"}
  ],
  steps: [
    %{
      id: "up",
      text: """
      You know exactly what the throat does now, and you step into it anyway.
      Maybe you told yourself you'd fight it from the inside. Maybe you just wanted,
      once, to be the one who gets to go up. The uptake takes you the way it takes
      everyone — gently, warmly, Aurel's voice somewhere saying he knew you'd make
      it. The last thing that's yours is the understanding of what's happening, and
      then the wire has you, and the Bloom goes on glittering below, and somewhere
      in the Latticework there's a new ghost that used to be a person with your name.
      You got everything the district promised. It goes quiet.
      """,
      choices: [
        %{label: "…", complete: true}
      ]
    }
  ]
}
