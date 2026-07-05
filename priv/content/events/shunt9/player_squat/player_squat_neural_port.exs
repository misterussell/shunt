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
      # This is the Chrome & Meat concept-seed, parallel to the deck (:ghostwork) and chits
      # (:authority_networks) starter events. The atom key is intentional and consistent with those
      # siblings; it is only a "you've discovered this skill" marker and is never used as a gate (the
      # v1 chrome loop gates on the patchwork_scalpel tool + the schematic Mira teaches). The first
      # real implant is the lineman_graft, not a port — the port stays a later/Ghostwork-facing mod.
      rewards: [
        {:knowledge, :augmentations}
      ],
      choices: [
        %{label: "Put the burnt-out port away. You'll find a way to fix it later."}
      ]
    }
  ]
}
