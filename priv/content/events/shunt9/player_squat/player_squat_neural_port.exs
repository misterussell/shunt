%Shunt.Events.Event{
  id: "shunt9_player_squat_neural_port",
  title: "Burnt-Out Neural Port",

  steps: [
    %{
      id: "inspect",
      text: """
      A discarded neural port sits among your belongings, damaged beyond use.
      You remember when it still answered your thoughts and let you jack in to all sorts of tech.
      """,
      choices: [
        %{label: "Pry it open", next: "wiring"},
        %{label: "Toss it aside"}
      ]
    },
    %{
      id: "wiring",
      text: """
      The wiring inside is scorched, but the housing still holds the
      manufacturer's mark — bootleg chrome & meat work, through and through. If you can get your hand on a patchwork scalpel and some solder you might be able to start modding your flesh and get a new port installed. It won't be pretty, but it will work.
      """,
      rewards: [
        {:knowledge, :augmentations}
      ],
      choices: [
        %{label: "Put the burnt-out port away. You'll find a way to fix it later."}
      ]
    }
  ]
}
