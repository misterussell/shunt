alias Shunt.World.Exit

%{
  id: "bloom_spread",
  name: "The Spread",
  short_description: "The dining hall — where the Bloom deals its rumors over dinner.",
  description:
    "The long room of the eat petal, tables laid with salvaged luxury and lit to flatter. The food is the excuse; the real course is talk. More of the Bloom's rumors are set at the Spread than anywhere else — a spread of dishes, a spread of stories.",
  tags: [:midgrid, :dining, :social],
  graph_position: {2790, -1960},

  # TODO: primary Web rumor hub — NPC(s) trading gossip over dinner; several rumor-source events;
  # atmosphere on :season (the room's talk warms from polite to vicious). Seed multiple rumors
  # here. The "bloom_reserve_invited" flag that opens the private booths is earned here.
  npcs: [],
  events: ["bloom_the_table"],
  exits: [
    %Exit{id: "spread_to_throat", to: "bloom_throat"},
    # The booths are invitation-only.
    %Exit{
      id: "spread_to_reserve",
      to: "bloom_reserve",
      requirements: [{:knows, "bloom_reserve_invited"}]
    },
    %Exit{id: "spread_to_galley", to: "bloom_galley"}
  ]
}
