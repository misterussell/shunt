%Shunt.Events.Event{
  id: "shunt9_bazaar_juno_deliver_parcel",
  title: "Deliver the Parcel",

  requirements: [
    {:has_item, "juno_parcel"}
  ],

  on_complete: [
    {:inventory, "juno_parcel", -1},
    {:inventory, "juno_delivery_receipt", 1}
  ],

  steps: [
    %{
      id: "handoff",
      text: """
      The contact at the far end of the stalls takes the parcel without a word,
      checks the tape, and slides a folded receipt back across the counter.
      """,
      choices: [
        %{label: "Take the receipt and go", complete: true}
      ]
    }
  ]
}
