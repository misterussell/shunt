%Shunt.Events.Event{
  id: "shunt9_bazaar_juno_supplier_investigation_report",
  title: "Sell the Information",

  requirements: [
    {:has_item, "juno_supplier_dossier"}
  ],

  on_complete: [
    {:inventory, "juno_supplier_dossier", -1},
    {:scrip, 150},
    {:modify_rep, "juno", :trust, 10}
  ],

  steps: [
    %{
      id: "sell",
      text: """
      You put the dossier on the table. Juno reads it slowly, her expression
      unreadable. Then she closes it and names a number. Fair, by her standards.
      """,
      choices: [
        %{label: "Take the money", complete: true}
      ]
    }
  ]
}
