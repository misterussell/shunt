%Shunt.Events.Event{
  id: "shunt9_bazaar_juno_move_package_report",
  title: "Report Back to Juno",

  requirements: [
    {:has_item, "juno_delivery_receipt"}
  ],

  on_complete: [
    {:inventory, "juno_delivery_receipt", -1},
    {:scrip, 50},
    {:modify_rep, "juno", :trust, 10},
    {:npc_progression, "shunt9_bazaar_juno", 1}
  ],

  steps: [
    %{
      id: "report",
      text: """
      You lay the receipt on the table. Juno glances at it, pockets it, and
      counts out the second half without being asked. "Told you it was simple."
      """,
      choices: [
        %{label: "Collect the rest", complete: true}
      ]
    }
  ]
}
