%Shunt.Events.Event{
  id: "liftworks_transfer_row_licensed_goods",
  title: "Licensed Goods",

  steps: [
    %{
      id: "browse",
      text: """
      You walk the row. A vendor quotes you a price and doesn't move off it.
      "Tariff's in the number," she says, not unkindly. "You're paying for it to
      be boring. No knock-offs, no shorted weight, no one selling your face to
      the desk." She nods at the stamped permit on her frame. "Boring's worth
      something this close to up."
      """,
      choices: [
        %{label: "Fair enough"}
      ]
    }
  ]
}
