%Shunt.Events.Event{
  id: "liftworks_watch_office_pressure",
  title: "Extra Shifts",

  on_complete: [
    {:rumor, "checkpoint_pressure"}
  ],

  steps: [
    %{
      id: "notice",
      text: """
      Two officers where one usually stands. The terminal cycling through the
      feed at an interval it normally doesn't bother with. Whatever the Watch
      Office is watching for, it isn't the queue — the queue is moving fine.
      Something else has them running double.
      """,
      choices: [
        %{label: "Note it", complete: true},
        %{label: "Leave it"}
      ]
    }
  ]
}
