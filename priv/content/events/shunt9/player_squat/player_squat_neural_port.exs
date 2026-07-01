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
      # TODO: [Chrome & Meat v1 — Milestone 4] Reconcile this intro with the v1 first implant:
      #   1. `:augmentations` is an ATOM but player.knowledge is {:array, :string} and {:knows, key}
      #      compares against strings — decide the canonical knowledge key ("augmentations") and make
      #      the grant and any downstream {:knows, ...} gate agree. (Check whether existing content
      #      relies on the atom before changing it.)
      #   2. Light-touch the "get a new port installed" wording so it seeds the skill without
      #      over-promising a neural port — the v1 first install is the lineman_graft, not a port.
      #      (The port stays a natural later/Ghostwork-facing implant.)
      rewards: [
        {:knowledge, :augmentations}
      ],
      choices: [
        %{label: "Put the burnt-out port away. You'll find a way to fix it later."}
      ]
    }
  ]
}
