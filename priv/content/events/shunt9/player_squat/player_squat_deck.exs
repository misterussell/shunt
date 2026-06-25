%Shunt.Events.Event{
  id: "shunt9_player_squat_deck",
  title: "Broken Deck",

  steps: [
    %{
      id: "inspect",
      text: """
      Your Deck lies cracked and silent.
      Once it linked you to the Latticework, the omnipotent data layer of the city. With it, you could have accessed the city's systems, but now it is useless.
      Unless you can repair it, you will be unable to access the Latticework again.
      """,
      choices: [
        %{label: "Examine circuitry", next: "circuitry"},
        %{label: "Check the owners manual", next: "manual"},
        %{label: "Leave it alone"}
      ]
    },
    %{
      id: "circuitry",
      text: """
      Most of the hardware can be salvaged, but the lattice coupler is ruined.
      If you scavenge the right parts, and make a new jury-rigged terminal you might be able to join the Latticework again.
      Hope isn't lost yet. All you need is a little bit of street alchemy and some luck, oh, and a soldering iron and at least 10 hours of free time.
      """,
      rewards: [
        {:knowledge, :ghostwork}
      ],
      choices: [
        %{label: "Tuck the broken deck away. You'll find a way to fix it later."}
      ]
    },
    %{
      id: "manual",
      text: """
      The owners manual is torn and water-damaged, but you can make out some useful information about the Deck's internals.
      It also explains how the deck was designed to interface with the Latticework. An interesting read any night of the week.
      """,
      choices: [
        %{label: "Set the manual next to the dead deck. You'll find a way to fix it later."}
      ]
    }
  ]
}
