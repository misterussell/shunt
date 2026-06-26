%Shunt.Events.Event{
  id: "shunt9_bazaar_juno_quiet_pickup",
  title: "Quiet Pickup",

  on_complete: [
    {:inventory, "juno_pickup_chit", 1},
    {:npc_progression, "shunt9_bazaar_juno", 1}
  ],

  steps: [
    %{
      id: "ask",
      text: """
      "Bigger one this time. A pickup I can't be seen near." Juno taps the table.
      "Do this clean and you're not just muscle to me anymore."
      """,
      choices: [
        %{label: "Where do I go?", next: "run"},
        %{label: "Too hot for me"}
      ]
    },
    %{
      id: "run",
      text: """
      Juno hands you a stamped chit. "Food stalls. Ask for whoever's working the
      far end. They'll sort you out — just show them the card."
      """,
      choices: [
        %{label: "Head over", complete: true}
      ]
    }
  ]
}
