alias Shunt.World.Exit

%{
  id: "shunt9_scrap_yard",
  name: "Scrap Yard",

  short_description:
    "Mountains of twisted metal loom overhead.",

  description:
    "Stripped chassis and dead drones are stacked in rusting heaps, picked over by scavvers with magnet rigs and cutting torches.",

  tags: [
    :salvage,
    :underbelly
  ],

  graph_position: {250, 230},

  lattice: %{
    leads: [
      %{
        id: "yard_manifest_signal",
        requirements: [],
        text:
          "A weak pulse under the static — old inventory data cycling through a dead terminal somewhere in the heaps.",
        on_intercept: [{:knowledge, "shunt9_yard_manifest_found"}]
      }
    ],
    filler: [
      %{
        weight: 3,
        text: "Stray EM from the mag-rigs washes out the channel. Nothing useful.",
        on_intercept: []
      },
      %{
        weight: 2,
        text: "A few loose credit fragments drift in on the open channel.",
        on_intercept: [{:scrip, 3}]
      }
    ]
  },

  npcs: [
    "shunt9_scrap_yard_grit"
  ],

  events: [
    "shunt9_scrap_yard_dead_terminal"
  ],

  exits: [
    %Exit{
      id: "scrap_yard_to_bazaar",
      to: "shunt9_bazaar"
    }
  ]
}
