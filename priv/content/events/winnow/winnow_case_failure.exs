%Shunt.Events.Event{
  id: "winnow_case_failure",
  title: "Just Grievances",
  repeatable: false,
  requirements: [],
  on_complete: [],
  steps: [
    %{
      id: "noise",
      text: """
      You lay out what you've got and it doesn't hold. A frightened girl on the Cull Line, a
      warden who hates his sums, a half-culled woman who talks in pieces — the Winnow is full
      of misery and none of it, by itself, proves the thing you can feel is true. You need
      the pattern, not the parts: the count and the door and the channel and what survives
      the wire, read together until they make one shape. Keep listening. The Floor is trying
      to tell you something. You haven't heard enough of it yet.
      """,
      choices: [
        %{label: "Keep listening", complete: true}
      ]
    }
  ]
}
