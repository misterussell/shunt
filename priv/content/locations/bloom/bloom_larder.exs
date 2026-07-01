alias Shunt.World.Exit

%{
  id: "bloom_larder",
  name: "The Larder",
  short_description: "Where the exotic provisions come in — salvaged luxury by the crate.",
  description:
    "The cold store at the end of the galley, stacked with what the Bloom eats: things grown, distilled, and salvaged from places the diners will never see. Half of it is a lie about where it came from, dressed up to sell.",
  tags: [:midgrid, :dining, :market],
  graph_position: {2440, -1880},

  # TODO: flavor/vendor — no core wiring required. Optional consumables fencing/vendor hook for
  # exotic provisions; a provisioner NPC for colour. Deepens the eat petal.
  npcs: [],
  events: [],
  exits: [
    %Exit{id: "larder_to_galley", to: "bloom_galley"}
  ]
}
