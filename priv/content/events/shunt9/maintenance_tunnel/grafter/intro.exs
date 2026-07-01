%Shunt.Events.Event{
  id: "shunt9_maintenance_tunnel_grafter_intro",
  title: "The Hand That Grafts",

  on_complete: [
    {:npc_progression, "shunt9_maintenance_tunnel_grafter", 1},
    {:contact, "shunt9_grafter"},
    {:knowledge, "schematic_lineman_graft"}
  ],

  steps: [
    %{
      id: "bench",
      text: """
      Since the grid came back a woman set up in the tunnel's dead end — a folding table,
      a jar of alcohol, a tray of parts that used to be inside people. She's tightening a
      clamp on her own forearm when you come up, watching a graft settle under the skin.
      "Power's on, so I'm open," she says. "Mira. I put chrome in meat for people the real
      dens won't touch. Nothing pretty. Things that work."
      """,
      choices: [
        %{label: "What can you do for me?", next: "offer"},
        %{label: "Where do the parts come from?", next: "supply"}
      ]
    },
    %{
      id: "offer",
      text: """
      "First one's the one you'll thank me for down at the relay. A lineman's graft —
      insulated weave in the hands, a servo for grip. Grab a live bus with it and you keep
      your fingers." She sketches it on the table in grease. "I'll give you the pattern.
      Chrome side, you pull a servo out of the scrap yard — the heaps are full of them. Meat
      side, you need a nerve sheath, and those you strip off what the fire left on the burned
      platform. Not pretty work. Bring me both, fab it, and you're grafting. Your load goes up
      either way — everything you bolt on, the readers see a little more of you."
      """,
      choices: [
        %{label: "Give me the pattern", complete: true}
      ]
    },
    %{
      id: "supply",
      text: """
      "Best surgical stock comes up from below. There's a crowd calls themselves the Fleshless —
      think meat's a rough draft — and they move parts nobody else can get." She shrugs, taps the
      seam on her arm. "I don't sign their book. But for the crude work you don't need them — the
      district's full of chrome and meat if you're willing to dig. You'll hear more about the
      Fleshless the higher you climb." She slides a greased sketch across the table. "Here. The
      pattern's yours. Servo from the yard, sheath off the scorch, and we'll make a start."
      """,
      choices: [
        %{label: "Take the pattern", complete: true}
      ]
    }
  ]
}
