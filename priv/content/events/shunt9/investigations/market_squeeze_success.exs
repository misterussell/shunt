%Shunt.Events.Event{
  id: "market_squeeze_success",
  title: "Spot-Rent",
  repeatable: false,

  on_complete: [
    {:scrip, 60},
    {:knowledge, "shunt9_market_squeeze_exposed"},
    {:npc_loyalty, "shunt9_bazaar_wrench", 5},
    {:npc_loyalty, "shunt9_food_stalls_ladle", 5}
  ],

  steps: [
    %{
      id: "reveal",
      text: """
      The three threads braid into one. The spot-fee, the chits, the choked
      supply lines — it's one operation, not three problems. A crew has quietly
      claimed the platform and they're charging every stall to stand on it. The
      short supply isn't bad luck; it's the squeeze. Pay the chit or starve out.

      They don't have muscle on every corner. What they have is everyone
      believing they do.
      """,
      choices: [
        %{label: "Use it", next: "use"}
      ]
    },
    %{
      id: "use",
      text: """
      You don't need to break the crew. You need the stalls to see the shape of
      it — that the rent is a story being sold to them one frightened vendor at a
      time. A word in the right ears at the bench and the wok, and the market
      starts comparing notes instead of paying quietly.

      Wrench slips you something for your trouble. Ladle just stops charging you
      for the bowl. Both of them remember who pulled the thread.
      """,
      choices: [
        %{label: "Bank it", complete: true}
      ]
    }
  ]
}
