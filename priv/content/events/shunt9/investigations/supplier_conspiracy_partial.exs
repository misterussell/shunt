%Shunt.Events.Event{
  id: "supplier_conspiracy_partial",
  title: "Partial Read",
  repeatable: true,

  on_complete: [
    {:rumor, "authority_involvement"}
  ],

  steps: [
    %{
      id: "partial",
      text: """
      The pieces fit, but not tightly enough. You can see the shape of the
      operation — hardware moving off the books, someone on the inside making it
      possible — but the middle layer is still missing. Who's keeping the
      paperwork clean?

      One thing is clear: whoever it is has transit authority credentials. The
      cargo sign-offs are too consistent to be coincidence.
      """,
      choices: [
        %{label: "Keep digging", complete: true}
      ]
    }
  ]
}
