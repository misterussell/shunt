%Shunt.Events.Event{
  id: "shunt9_bazaar_juno_odd_job",
  title: "Odd Job",
  repeatable: true,

  on_complete: [
    {:inventory, "juno_odd_job_parcel", 1}
  ],

  steps: [
    %{
      id: "ask",
      text: """
      "Always something needs moving." Juno slides a small parcel across the
      table. "Food stalls. You know who."
      """,
      choices: [
        %{label: "On it", complete: true},
        %{label: "Maybe later"}
      ]
    }
  ]
}
