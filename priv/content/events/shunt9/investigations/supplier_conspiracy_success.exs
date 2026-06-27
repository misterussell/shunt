%Shunt.Events.Event{
  id: "supplier_conspiracy_success",
  title: "Supply Line",
  repeatable: false,

  on_complete: [
    {:discover_location, "shunt9_freight_tunnel"},
    {:contact, "dex_broker"},
    {:rumor, "freight_tunnel_shipments"},
    {:scrip, 200}
  ],

  steps: [
    %{
      id: "reveal",
      text: """
      The theory holds. Corporate hardware is moving through Shunt 9 on a ghost
      route — the old freight tunnel, listed as decommissioned but running clean.
      Vex is the transit authority contractor signing off on manifests that should
      never clear. His debts are the leverage keeping him cooperative.

      The broker in the middle works the food stalls. Goes by Dex.
      """,
      choices: [
        %{label: "Pull the thread", next: "pull"}
      ]
    },
    %{
      id: "pull",
      text: """
      You know the route. You know the players. That's worth real money or
      something better than money, depending on what you do with it.

      The freight tunnel is active and you know how to reach it. Dex is a contact
      now. And the cargo is still moving.
      """,
      choices: [
        %{label: "Mark it", complete: true}
      ]
    }
  ]
}
