%Shunt.Events.Event{
  id: "bloom_ascent_partial",
  title: "A Shape in the Dark",
  repeatable: false,
  requirements: [],
  on_complete: [],
  steps: [
    %{
      id: "partial",
      text: """
      There's enough here to be sure of one thing: the dream is a lie. People go up
      and don't come back, and the going-up is arranged, not earned. But the middle
      of it is still dark — how it's done, what it's for, who at the top is really
      pulling the names. You've got the outline of a horror without its face. A few
      more threads and it'll come clear. Keep pulling.
      """,
      choices: [
        %{label: "Keep pulling", complete: true}
      ]
    }
  ]
}
