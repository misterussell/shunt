%Shunt.Events.Event{
  id: "liftworks_watch_office_terminal",
  title: "The Records Terminal",

  on_complete: [
    {:knowledge, "permit_registry_found"}
  ],

  steps: [
    %{
      id: "look",
      text: """
      The duty officer is three screens deep in something that isn't the queue.
      The records terminal in the corner sits unlocked, the way things do in
      rooms nobody's supposed to be able to enter. Permits issued. Tags flagged.
      Every name that's gone up or been turned back, written down and reachable.
      """,
      choices: [
        %{label: "Get a read on the system", next: "read"},
        %{label: "Leave it — the officer's right there"}
      ]
    },
    %{
      id: "read",
      text: """
      It's a permit registry, wired straight into the Latticework — older than
      the arch and twice as trusting. You don't touch it now, not with the
      officer breathing in the same room. But you've seen the shape of it.
      Somewhere quieter, with your deck, it would open.
      """,
      choices: [
        %{label: "File it away", complete: true}
      ]
    }
  ]
}
