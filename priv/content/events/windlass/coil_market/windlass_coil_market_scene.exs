%Shunt.Events.Event{
  id: "windlass_coil_market_scene",
  title: "Nothing Moves Free",
  repeatable: false,

  steps: [
    %{
      id: "floor",
      text: """
      The market takes you in and prices you before you've bought anything — a
      dozen stalls clocking your boots, your kit, the heat you're carrying. A
      hawker catches your eye, glances at the reader over her stall, and quietly
      names you two prices: one for the record, one for cash. Everything on these
      turns runs twice, once for the Authority and once for the truth. Behind it
      all, in a booth with no goods, someone is keeping the only ledger that
      matters.
      """,
      choices: [
        %{label: "Find out who keeps the ledger", complete: true}
      ]
    }
  ]
}
