%Shunt.Events.Event{
  id: "shunt9_bazaar_wrench_intro",
  title: "Wrench",

  on_complete: [
    {:npc_progression, "shunt9_bazaar_wrench", 1},
    {:inventory, "cracked_datachip", 1}
  ],

  steps: [
    %{
      id: "stall",
      text: """
      A stall built out of a gutted equipment locker, every shelf sorted by a
      logic only the owner understands. A wiry figure sits behind it sorting a
      tray of screws by hand, not looking up. "You're new. New ones always come
      to me last, after they've paid Rook too much for parts they could've found
      in the heaps." A pause. "Name's Wrench. I sell what works."
      """,
      choices: [
        %{label: "What've you got?", next: "stock"},
        %{label: "Just passing", next: "passing"}
      ]
    },
    %{
      id: "stock",
      text: """
      "Salvage, mostly. Coils, boards, the odd chip that still holds a charge."
      Wrench finally looks at you, takes in the dead deck you're not quite hiding.
      "That thing. You're trying to bring it back, you'll need a coupler and a
      live datachip to boot the firmware. Here." A cracked datachip lands on the
      counter between you. "First one's on the house. Get it running, you'll be
      back for the rest."
      """,
      choices: [
        %{label: "Take it", complete: true}
      ]
    },
    %{
      id: "passing",
      text: """
      "Everybody's passing, till their gear breaks." Wrench goes back to the
      screws. "I'll be here. I'm always here." A cracked datachip slides to your
      side of the counter anyway. "Take it. Bring me business when that deck of
      yours matters again."
      """,
      choices: [
        %{label: "Pocket it", complete: true}
      ]
    }
  ]
}
