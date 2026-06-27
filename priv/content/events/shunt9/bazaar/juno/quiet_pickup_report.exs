%Shunt.Events.Event{
  id: "shunt9_bazaar_juno_quiet_pickup_report",
  title: "Report the Pickup",

  requirements: [
    {:has_item, "juno_pickup_goods"}
  ],

  on_complete: [
    {:inventory, "juno_pickup_goods", -1},
    {:modify_rep, "juno", :trust, 10},
    {:modify_rep, "juno", :favors, 1},
    {:knowledge, "juno_secret_supplier"},
    {:rumor, "juno_supplier"}
  ],

  steps: [
    %{
      id: "report",
      text: """
      You set the bundle down. Juno doesn't open it — just runs a hand across
      the tape, satisfied. Then she talks looser than usual, and lets slip where
      the goods really come from.
      """,
      choices: [
        %{label: "File that away", complete: true}
      ]
    }
  ]
}
