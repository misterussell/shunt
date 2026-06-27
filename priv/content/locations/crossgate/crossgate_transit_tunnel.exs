alias Shunt.World.Exit

%{
  id: "crossgate_transit_tunnel",
  name: "Transit Tunnel",

  short_description:
    "A dark passage between Shunt 9 and The Crossgate.",

  description:
    "A sealed transit corridor — low ceiling, scorch marks on the walls, ventilation grates that haven't moved air in years. The floor shows heavy foot traffic in both directions. Someone has been using this tunnel regularly.",

  tags: [
    :infrastructure,
    :underbelly
  ],

  graph_position: {600, 230},

  events: [
    "crossgate_transit_tunnel_old_signage"
  ],

  exits: [
    %Exit{
      id: "transit_tunnel_to_burned_platform",
      to: "shunt9_burned_platform"
    },
    %Exit{
      id: "transit_tunnel_to_tollgate",
      to: "crossgate_tollgate"
    }
  ]
}
