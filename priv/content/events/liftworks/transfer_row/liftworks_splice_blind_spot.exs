%Shunt.Events.Event{
  id: "liftworks_splice_blind_spot",
  title: "Blind Spot",

  on_complete: [
    {:knowledge, "scan_arch_found"},
    {:npc_progression, "liftworks_splice", 1}
  ],

  steps: [
    %{
      id: "ask",
      text: """
      Splice doesn't look up from the board they're stripping. "The arch. Yeah,
      I wired half of it before they decided I wasn't cleared to know how it
      worked." A dry laugh. "They left the back of it talking to the old draw
      log. Nobody patched that. Nobody remembers it's there."
      """,
      choices: [
        %{label: "Show me where to push", next: "where"},
        %{label: "Maybe later"}
      ]
    },
    %{
      id: "where",
      text: """
      "Slot your deck at the arch housing on the intake floor. It'll answer like
      it's still 1990s infrastructure, because it is." Splice finally looks at
      you. "Crack it clean and it'll write you a tag the reader upstairs trusts.
      Crack it loud and you'll be the next one waved back. Your call."
      """,
      choices: [
        %{label: "I'll be clean", complete: true}
      ]
    }
  ]
}
