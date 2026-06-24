%Shunt.Events.Event{
  id: "shunt9_player_squat_deck",
  title: "Broken Deck",

  steps: [
    %{
      id: "inspect",
      text: """
      Your Deck lies cracked and silent.
      Once it linked you to the Latticework.
      """,
      choices: [
        %{label: "Examine circuitry", next: "circuitry"},
        %{label: "Leave it alone", complete: true}
      ]
    },
    %{
      id: "circuitry",
      text: """
      Most of the hardware can be salvaged,
      but the lattice coupler is ruined.
      """,
      rewards: [
        {:knowledge, :ghostwork}
      ],
      complete: true
    }
  ]
}
