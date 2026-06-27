%Shunt.Events.Event{
  id: "liftworks_writ_ghost_clearance",
  title: "Off the List",
  repeatable: false,

  requirements: [
    {:contact_known, "liftworks_writ"}
  ],

  on_complete: [
    {:scrip, -200},
    {:knowledge, "ghost_clearance"}
  ],

  steps: [
    %{
      id: "deal",
      text: """
      Writ doesn't look up from the terminal. "Name." You give it. They type
      something you can't see, wait, type something else. "Done. The reader
      will take you. Use the lift before next shift — I don't hold entries
      open." They name a price. It isn't negotiable and they don't say it
      twice.
      """,
      choices: [
        %{label: "Pay", next: "paid"},
        %{label: "Not now"}
      ]
    },
    %{
      id: "paid",
      text: """
      The scrip leaves your hand. Writ goes back to work without acknowledging
      the transaction. Your name is in the system under a tag that reads
      already-cleared — no permit, no arch, no one asking for paper. The lift
      will take you.
      """,
      choices: [
        %{label: "Go get your lift", complete: true}
      ]
    }
  ]
}
