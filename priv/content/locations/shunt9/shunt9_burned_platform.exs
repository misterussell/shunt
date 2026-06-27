alias Shunt.World.Exit

%{
  id: "shunt9_burned_platform",
  name: "Burned Platform",

  short_description:
    "A scorched transit platform, long since abandoned.",

  description:
    "Soot-blackened girders mark where a fire gutted this stretch of the line years ago. Nobody talks about how it started.",

  tags: [
    :ruins,
    :underbelly
  ],

  graph_position: {400, 400},

  lattice: %{
    leads: [
      %{
        id: "transit_door_ice_signal",
        requirements: [],
        text:
          "A tight, current-spec security signal — the door at the far end of the platform is running active ICE, not dead tech.",
        on_intercept: [{:knowledge, "shunt9_burned_platform_transit_ice_found"}]
      }
    ],
    filler: [
      %{
        weight: 3,
        text: "Stray signal from the platform's old transit systems — nothing useful.",
        on_intercept: []
      },
      %{
        weight: 2,
        text: "A fragment of old ticketing data washes through. Worth a few scrip.",
        on_intercept: [{:scrip, 2}]
      }
    ]
  },

  npcs: [
    "shunt9_burned_platform_cinder"
  ],

  events: [
    "shunt9_burned_platform_melted_door",
    "shunt9_burned_platform_scorched_records",
    "shunt9_burned_platform_transit_door"
  ],

  exits: [
    %Exit{
      id: "burned_platform_to_bazaar",
      to: "shunt9_bazaar"
    },
    %Exit{
      id: "burned_platform_to_maintenance_tunnel",
      to: "shunt9_maintenance_tunnel"
    },
    %Exit{
      id: "burned_platform_to_transit_tunnel",
      to: "crossgate_transit_tunnel",
      requirements: [
        {:knows, "crossgate_transit_unlocked"}
      ]
    }
  ]
}
