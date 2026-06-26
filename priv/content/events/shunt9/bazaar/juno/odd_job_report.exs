%Shunt.Events.Event{
  id: "shunt9_bazaar_juno_odd_job_report",
  title: "Collect Your Cut",
  repeatable: true,

  requirements: [
    {:has_item, "juno_odd_job_receipt"}
  ],

  on_complete: [
    {:inventory, "juno_odd_job_receipt", -1},
    {:scrip, 20},
    {:modify_rep, "juno", :trust, 2}
  ],

  steps: [
    %{
      id: "collect",
      text: """
      Juno glances at the receipt and counts out your cut without looking up.
      "Same time next time."
      """,
      choices: [
        %{label: "Take it", complete: true}
      ]
    }
  ]
}
