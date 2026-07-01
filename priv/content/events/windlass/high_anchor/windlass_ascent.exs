%Shunt.Events.Event{
  id: "windlass_ascent",
  title: "The Way Up",
  repeatable: false,

  requirements: [
    {:knows, "windlass_case_cracked"}
  ],

  on_complete: [
    {:knowledge, "windlass_ascended"}
  ],

  steps: [
    %{
      id: "gate",
      text: """
      The lift-shaft climbs out of the Windlass toward the last district before the
      Spire, and for the first time the way up is yours to take. You know the whole
      shape of it now — the pulled governor, the bought report, the standing order
      to hold the freight and clear the count, signed off High Anchor before the
      engine ever stopped. What you do with the truth is the last thing the Windlass
      asks of you. Then you climb.
      """,
      choices: [
        %{label: "Ride the freight up — you woke the engine", next: "freight"},
        %{label: "Go up dark — the Collective spoofs the arch", next: "smuggled"},
        %{label: "Take the permit — leave quiet, leave clean", next: "permit"},
        %{label: "Publish the order first — let it burn", next: "expose"}
      ]
    },
    %{
      id: "freight",
      text: """
      You ride up the way freight does, in the cage the great screw hauls, the coil
      turning under you because you made it turn. Slagfoot recedes below — furnaces
      lit, cranes working, Ratchet somewhere down there watching his engine run and
      knowing what it cost the liars. You didn't burn the Windlass down. You made it
      work, which in this place is the harder and rarer thing. The last district
      opens above you.
      """,
      choices: [
        %{label: "Climb", complete: true}
      ]
    },
    %{
      id: "smuggled",
      text: """
      The Collective takes the arch apart from the inside as you walk through it —
      readers going dark, the permit registry seeing a name that was never there.
      The grid runs open behind you, top to bottom, the Authority blind in its own
      district for the first time in years. Drift's people melt back into the wires.
      You go up a ghost, the way you came up out of the Underbelly, except this time
      you left the door open behind you. The last district opens above.
      """,
      choices: [
        %{label: "Climb", complete: true}
      ]
    },
    %{
      id: "permit",
      text: """
      Vane is as good as his word, which is its own kind of sickening. The permit
      is real, the climb is easy, the arch waves you through like it waves through
      everyone the grid has decided to forget about. You go up clean and quiet,
      carrying what you know and telling no one, a friend of the Ascent Office. The
      Windlass keeps its lie a while longer. But you keep the truth, and you're not
      finished climbing. The last district opens above — and someday, so will this.
      """,
      choices: [
        %{label: "Climb", complete: true}
      ]
    },
    %{
      id: "expose",
      text: """
      Before you climb, you put the order where it can't be unsent — every reader
      in the Windlass, every deck in the Fitworks, the whole district reading the
      signature at once. High Anchor's certification dies on the desk. The purge
      list is paper now, just paper. It'll cost people, and some of them will be the
      wrong people, because the truth always does. But Marrow's name comes off a
      list tonight, and that has to be worth the climb. You go up loud. The last
      district opens above.
      """,
      choices: [
        %{label: "Climb", complete: true}
      ]
    }
  ]
}
