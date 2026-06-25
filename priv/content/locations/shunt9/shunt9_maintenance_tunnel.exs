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

  npcs: [
    "shunt9_maintenance_tunnel_junkie"
  ],

  events: [
    "shunt9_maintenance_tunnel_security_panel"
  ],

  exits: [
    %Exit{
      id: "maintenance_tunnel_to_burned_platform",
      to: "shunt9_burned_platform"
    },
    %Exit{
      id: "maintenance_tunnel_to_player_squat",
      to: "shunt9_player_squat"
    }
  ]
}
