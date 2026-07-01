%Shunt.Events.Event{
  id: "bloom_ascent_failure",
  title: "Crossed Wires",
  repeatable: false,
  requirements: [],
  on_complete: [],
  steps: [
    %{
      id: "failure",
      text: """
      The threads don't tie. You've got pieces of three different stories wired
      into one, and the shape they make is nonsense — coincidence dressed as
      conspiracy. Somewhere in here is the real thing, you're sure of it, but this
      isn't it. Pull the board apart and start the connections again, cleaner this
      time.
      """,
      choices: [
        %{label: "Start over", complete: true}
      ]
    }
  ]
}
