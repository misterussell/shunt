%Shunt.Events.Event{
  id: "shunt9_bazaar_juno_odd_job",
  title: "Odd Job",

  on_complete: [
    {:scrip, 20},
    {:modify_rep, "juno", :trust, 2}
  ],

  steps: [
    %{
      id: "ask",
      text: """
      "Always something needs moving." Juno jerks a thumb toward a crate. "Quick
      one, if you've got the time."
      """,
      choices: [
        %{label: "Handle it", complete: true},
        %{label: "Maybe later"}
      ]
    }
  ]
}
