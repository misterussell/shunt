alias Shunt.World.Exit

%{
  id: "bloom_galley",
  name: "The Galley",
  short_description: "The service back of the Spread — steam, sweat, and the way into the vents.",
  description:
    "Behind the dining hall, the galley runs hot and hidden: prep tables, the crews who never sit at them, and a service hatch that opens onto the vent spine. The people who plate the Bloom's excess see more of how it's made than the diners ever will.",
  tags: [:midgrid, :dining, :infrastructure],
  graph_position: {2700, -1830},

  # TODO: pocket-of-C grooming imagery (the believed meat-cover flavour — the crop being fattened
  # and finished); the back-route hinge from the eat petal into the Vent Run; optional
  # kitchen-worker NPC who's seen too much and can be turned into a lead.
  npcs: ["bloom_pia"],
  events: [],
  exits: [
    %Exit{id: "galley_to_spread", to: "bloom_spread"},
    %Exit{id: "galley_to_larder", to: "bloom_larder"},
    %Exit{id: "galley_to_vent_run", to: "bloom_vent_run"}
  ]
}
