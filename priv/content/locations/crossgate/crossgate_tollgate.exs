alias Shunt.World.Exit

%{
  id: "crossgate_tollgate",
  name: "The Tollgate",

  short_description:
    "The Syndicate's checkpoint. Everyone pays to pass.",

  description:
    "A chokepoint built into the mouth of the transit tunnel, where two former ticket booths have been reinforced into guard posts. The Syndicate's mark — a closed fist pressed in red paint — is on every surface. You don't enter The Crossgate without being counted.",

  tags: [
    :syndicate,
    :underbelly
  ],

  graph_position: {750, 230},

  npcs: [
    "crossgate_tollgate_ratchet"
  ],

  exits: [
    %Exit{
      id: "tollgate_to_transit_tunnel",
      to: "crossgate_transit_tunnel"
    },
    %Exit{
      id: "tollgate_to_concourse",
      to: "crossgate_concourse"
    }
  ]
}
