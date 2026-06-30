alias Shunt.World.Exit

%{
  id: "shunt9_maintenance_tunnel",
  name: "Maintenance Tunnel",

  short_description:
    "A narrow service tunnel running under the platform.",

  description:
    "Pipes and conduit lines run along the low ceiling, dripping condensation onto a walkway that hasn't seen an official inspection in years.",

  tags: [
    :infrastructure,
    :underbelly
  ],

  graph_position: {550, 400},

  lattice: %{
    leads: [
      %{
        id: "abandoned_relay_signal",
        requirements: [],
        text:
          "Under the panel's chatter, a maintenance relay is still broadcasting on a frequency the crews abandoned years ago.",
        on_intercept: [{:knowledge, "shunt9_abandoned_relay_found"}]
      }
    ],
    filler: [
      %{
        weight: 3,
        text: "Stray feed fragments resolve into a few loose credits.",
        on_intercept: [{:scrip, 3}]
      },
      %{
        weight: 2,
        text: "Nothing but the panel's heartbeat and the drip of the ceiling.",
        on_intercept: []
      }
    ]
  },

  npcs: [
    "shunt9_maintenance_tunnel_junkie"
  ],

  events: [
    "shunt9_maintenance_tunnel_security_panel",
    "shunt9_maintenance_tunnel_relay_stash"
  ],

  exits: [
    %Exit{
      id: "maintenance_tunnel_to_burned_platform",
      to: "shunt9_burned_platform"
    },
    %Exit{
      id: "maintenance_tunnel_to_player_squat",
      to: "shunt9_player_squat"
    },
    %Exit{
      id: "maintenance_tunnel_to_cold_store",
      to: "shunt9_cold_store"
    },
    %Exit{
      id: "maintenance_tunnel_to_freight_tunnel",
      to: "shunt9_freight_tunnel",
      requirements: [{:contact_known, "dex_broker"}]
    }
  ]
}
