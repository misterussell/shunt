%Shunt.Events.Event{
  id: "winnow_arrival_spoiled",
  title: "Spat Out the Top",
  repeatable: false,
  requirements: [
    {:knows, "bloom_ascended"}
  ],
  on_complete: [
    {:knowledge, "winnow_arrived"}
  ],
  steps: [
    %{
      id: "wake",
      text: """
      You went up the throat expecting to end, and instead you wake — on a cold floor,
      in your own body, with the understanding still in your skull that should have
      been filed away by now. The wire took you and gave you back. Somewhere a belt is
      running. Someone in grey coveralls looks down at you the way you'd look at a crate
      that came apart in transit, and says, not unkindly, "Spoiled one." Not the way up
      you were promised. But you're still you, which up here is a defect, and a defect is
      the only thing that ever walks off this floor. This is the Spire. It's a basement.
      You start to understand you were never going to get anything else.
      """,
      choices: [
        %{label: "Get up", complete: true}
      ]
    }
  ]
}
