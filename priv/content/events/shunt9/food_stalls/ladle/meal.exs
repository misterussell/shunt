%Shunt.Events.Event{
  id: "shunt9_food_stalls_ladle_meal",
  title: "A Hot Bowl",
  repeatable: true,

  on_complete: [
    {:npc_loyalty, "shunt9_food_stalls_ladle", 1}
  ],

  steps: [
    %{
      id: "bowl",
      text: """
      Ladle has a bowl filled and pushed across before you've decided to ask for
      one. "Eat. You look like a relay that's about to trip." It's hot and it's
      salt and it's the first thing all day that hasn't tasted like the tunnel.
      Around you the row eats shoulder to shoulder, shouting orders, settling
      debts, half of Shunt 9 passing through one greasy stretch of platform.
      """,
      choices: [
        %{label: "Eat, and listen", complete: true}
      ]
    }
  ]
}
