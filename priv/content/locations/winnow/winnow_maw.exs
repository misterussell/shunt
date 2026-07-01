alias Shunt.World.Exit

%{
  id: "winnow_maw",
  name: "The Maw",
  short_description:
    "The top of the throat — where the flue empties out whatever the Bloom sent up.",
  description:
    "The throat doesn't open onto light. It opens here: a black iron gullet, wet with heat, that empties its haul onto a cold receiving floor and moves on. This is the first ground of the Spire, and it is a loading dock. Whatever the Bloom fed up the flue arrives at the Maw to be sorted, and what can't be used gets sent back down a different way. Nobody told the district below that the top was a basement.",
  tags: [:spire, :transit, :latticework],
  graph_position: {3000, -2480},

  # Entry seam from the Bloom: the up-exit lives on bloom_uptake (two gated exits, one per ending),
  # so this is where the Bloom's finale drops the player — spoiled (bloom_ascended) or exposed
  # (bloom_throat_starved). Both arrival events grant winnow_arrived. It's a one-way climb up into
  # the Spire; there is no exit back down into the harvested Bloom.
  npcs: [],
  events: ["winnow_arrival_spoiled", "winnow_arrival_exposed"],
  exits: [
    %Exit{id: "maw_to_sorting", to: "winnow_sorting_floor"},
    %Exit{id: "maw_to_cull", to: "winnow_cull_line"},
    %Exit{id: "maw_to_keep", to: "winnow_keep_line"}
  ]
}
