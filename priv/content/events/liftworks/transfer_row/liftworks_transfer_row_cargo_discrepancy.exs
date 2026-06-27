%Shunt.Events.Event{
  id: "liftworks_transfer_row_cargo_discrepancy",
  title: "Short Count",

  on_complete: [
    {:rumor, "cargo_discrepancy"}
  ],

  steps: [
    %{
      id: "browse",
      text: """
      You pull a vendor's permit from the frame and run the numbers — goods
      declared, goods on the shelf, month's manifest. They don't reconcile.
      The gap isn't large, and nobody is stressing about it. "Happens every
      quarter," the vendor says, not looking up. "Tariff office writes it off
      as variance. Nobody cares enough to chase."

      Nobody with a reason to be here, anyway.
      """,
      choices: [
        %{label: "File it", complete: true},
        %{label: "It's nothing"}
      ]
    }
  ]
}
