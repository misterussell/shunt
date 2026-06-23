alias Shunt.World.Exit

%{
  key: "shunt9_maintenance_tunnel",
  name: "Maintenance Tunnel",

  short_description:
    "A narrow service tunnel running under the platform.",

  description:
    "Pipes and conduit lines run along the low ceiling, dripping condensation onto a walkway that hasn't seen an official inspection in years.",

  tags: [
    :infrastructure,
    :underbelly
  ],

  graph_position: {500, 700},

  exits: [
    %Exit{to: "shunt9_burned_platform"},
    %Exit{to: "shunt9_player_squat"}
  ]
}
