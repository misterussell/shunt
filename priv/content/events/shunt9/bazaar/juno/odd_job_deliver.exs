%Shunt.Events.Event{
  id: "shunt9_bazaar_juno_odd_job_deliver",
  title: "Drop the Parcel",
  repeatable: true,

  requirements: [
    {:has_item, "juno_odd_job_parcel"}
  ],

  on_complete: [
    {:inventory, "juno_odd_job_parcel", -1},
    {:inventory, "juno_odd_job_receipt", 1}
  ],

  steps: [
    %{
      id: "drop",
      text: """
      Dex takes it without a word and hands you a receipt. Same as always.
      """,
      choices: [
        %{label: "Take the receipt", complete: true}
      ]
    }
  ]
}
