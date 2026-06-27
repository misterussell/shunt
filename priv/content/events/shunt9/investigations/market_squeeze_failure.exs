%Shunt.Events.Event{
  id: "market_squeeze_failure",
  title: "Asking Around",
  repeatable: true,

  on_complete: [
    {:heat, 8}
  ],

  steps: [
    %{
      id: "burn",
      text: """
      The threads you tied don't hold, and you spent them asking loud questions
      in a small market. Stalls go quiet as you pass. Somewhere a collector hears
      that a new face is poking at the spot-rent, and decides to keep an eye on
      where that face sleeps.
      """,
      choices: [
        %{label: "Back off", complete: true}
      ]
    }
  ]
}
