%Shunt.Events.Event{
  id: "liftworks_clean_names_success",
  title: "Clean Names",
  repeatable: false,

  on_complete: [
    {:contact, "liftworks_writ"},
    {:knowledge, "ghost_clearance"},
    {:scrip, 150}
  ],

  steps: [
    %{
      id: "reveal",
      text: """
      The picture comes clear. Someone at the Watch Office has been running a
      quiet service alongside the official roster: flagged individuals routed
      through Proxy with new paper, then their watchlist entries pulled before
      the arch ever reads them. The registry says they're clean because someone
      with a duty officer's terminal access made it so.

      The name is Writ.
      """,
      choices: [
        %{label: "Make contact", next: "contact"}
      ]
    },
    %{
      id: "contact",
      text: """
      You find them on a quiet shift at the records terminal — unremarkable,
      methodical, doing exactly what they're supposed to be doing and three
      other things besides. You let them know you've read the room.

      They don't turn around. "If something needs to not be on a list," they
      say, "you come to me. Don't come twice for the same thing." A pause.
      "Don't come loud."
      """,
      choices: [
        %{label: "Understood", complete: true}
      ]
    }
  ]
}
