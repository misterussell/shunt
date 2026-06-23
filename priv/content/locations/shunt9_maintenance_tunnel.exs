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
    %{to: "shunt9_burned_platform", requirements: []},
    %{to: "shunt9_player_squat", requirements: []}
  ]
}
