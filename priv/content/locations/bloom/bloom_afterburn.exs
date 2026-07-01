alias Shunt.World.Exit

%{
  id: "bloom_afterburn",
  name: "The Afterburn",
  short_description: "The pleasure-and-chem den deeper in the duct; you have to be let in.",
  description:
    "Past the Burnoff's noise, where the duct narrows and the light goes red, the Afterburn keeps the district's real appetites. What people won't say at the bar they say in here, loosened by whatever's going around.",
  tags: [:midgrid, :nightlife],
  graph_position: {2560, -2260},

  # TODO: gated den (via bloom_den_vouched). Street Alchemy chem flavour — possibly a consumable
  # the den moves; a rumor overheard here that's harder to get elsewhere; loyalty/Web content with
  # whoever runs the room. Connects to the Vent Run (the back-route hinge on the party side).
  npcs: [],
  events: [],
  exits: [
    %Exit{id: "afterburn_to_burnoff", to: "bloom_burnoff"},
    %Exit{id: "afterburn_to_ashfall", to: "bloom_ashfall"},
    %Exit{id: "afterburn_to_vent_run", to: "bloom_vent_run"}
  ]
}
