%Shunt.Events.Event{
  id: "liftworks_proxy_papers",
  title: "Papers, Then",

  on_complete: [
    {:scrip, -100},
    {:heat, 12},
    {:inventory, "transit_permit", 1},
    {:npc_progression, "liftworks_proxy", 1}
  ],

  steps: [
    %{
      id: "deal",
      text: """
      "Paper, then." Proxy doesn't take notes; she takes scrip. "Cheaper than
      Stamp's tariff and faster, and that's the whole price right up front —
      except it isn't." She meets your eye. "A forged permit reads fine until
      someone runs it. You'll be up top before they do. Probably. The heat lands
      on you, not me. That's the rest of the cost."
      """,
      choices: [
        %{label: "Do it", next: "hand"},
        %{label: "Too rich for me"}
      ]
    },
    %{
      id: "hand",
      text: """
      She produces a permit already warm, already marked, indistinguishable from
      the real thing because the difference is only ever in the record. "Reader
      takes it at the Risers. Don't be memorable on the way." She's looking past
      you before you've stood up. You're carrying something that can get you up —
      or get you noticed.
      """,
      choices: [
        %{label: "Pocket the permit", complete: true}
      ]
    }
  ]
}
