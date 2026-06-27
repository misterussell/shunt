%Shunt.Events.Event{
  id: "crossgate_register_liftworks_word",
  title: "A Word on the Liftworks",

  on_complete: [
    {:knowledge, "liftworks_route"}
  ],

  steps: [
    %{
      id: "ask",
      text: """
      You ask Cipher about the way up — the real way, not the rumors. A long
      look, then: "There's a checkpoint past the Concourse. Old freight lifts.
      The Authority runs it clean, which means it runs it slow."
      """,
      choices: [
        %{label: "How do I get in?", next: "route"},
        %{label: "Not today"}
      ]
    },
    %{
      id: "route",
      text: """
      "Through the Concourse, north side, where the crowd thins out. Door's not
      marked but it's not hidden either." Cipher shrugs. "Getting in is easy.
      Getting *up* is the part that costs you."
      """,
      choices: [
        %{label: "Good to know", complete: true}
      ]
    }
  ]
}
