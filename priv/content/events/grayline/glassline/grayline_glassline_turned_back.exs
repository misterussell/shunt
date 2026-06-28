%Shunt.Events.Event{
  id: "grayline_glassline_turned_back",
  title: "No Read",
  repeatable: true,

  steps: [
    %{
      id: "line",
      text: """
      You drift toward a turnstile and let the reader take a look at you. It finds
      nothing — no record, no history, no person where a person should be — and
      does the worst thing a machine can do, which is nothing at all. The gate
      doesn't open. It doesn't refuse you either. To the grid you simply aren't.
      A watchman's gaze swings your way. Not yet. You step back into the Grayline,
      where weightless is still allowed to stand somewhere.
      """,
      choices: [
        %{label: "Step back"}
      ]
    }
  ]
}
