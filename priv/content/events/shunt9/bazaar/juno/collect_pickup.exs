%Shunt.Events.Event{
  id: "shunt9_bazaar_juno_collect_pickup",
  title: "Collect the Pickup",

  requirements: [
    {:has_item, "juno_pickup_chit"}
  ],

  on_complete: [
    {:inventory, "juno_pickup_chit", -1},
    {:inventory, "juno_pickup_goods", 1}
  ],

  steps: [
    %{
      id: "collect",
      text: """
      You show the chit. The contact disappears behind a curtain and comes back
      with a wrapped bundle, heavier than it looks. No words, no names. Just the
      exchange.
      """,
      choices: [
        %{label: "Take it and go", complete: true}
      ]
    }
  ]
}
