%Shunt.Events.Event{
  id: "shunt9_player_squat_neural_port",
  title: "Burnt-Out Neural Port",

  steps: [
    %{
      id: "inspect",
      text: """
      A discarded neural port sits among your belongings, damaged beyond use.
      You remember when it still answered your thoughts.
      """,
      choices: [
        %{label: "Pry it open", next: "wiring"},
        %{label: "Toss it aside", complete: true}
      ]
    },
    %{
      id: "wiring",
      text: """
      The wiring inside is scorched, but the housing still holds the
      manufacturer's mark — Chrome & Meat work, through and through.
      """,
      rewards: [
        {:knowledge, :augmentations}
      ],
      complete: true
    }
  ]
}
