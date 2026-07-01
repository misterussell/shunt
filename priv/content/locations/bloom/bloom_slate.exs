alias Shunt.World.Exit

%{
  id: "bloom_slate",
  name: "The Slate",
  short_description: "The betting market on who ascends next — the Bloom's rumor-price ticker.",
  description:
    "A wall of shifting odds and the crowd that lives and dies by them: the Slate takes wagers on who the Spire calls up next, and the numbers move on rumor the way a market moves on news. Read the Slate and you read the whole district's fear.",
  tags: [:midgrid, :gambling, :latticework, :social],
  graph_position: {3210, -1960},

  # TODO — Ghostwork target + Web engine:
  #   - lattice block whose leads find the way into the betting system; the ICE node
  #     "bloom_slate_ice" (ice_nodes/bloom/) whose reward grants the ICE-LOCKED rumor the finale
  #     RumorConnection requires (this is what forces a full Ghostwork crack).
  #   - the market as a hackable system (rig/read the odds, skim the pool) — Ghostwork rewards.
  #   - :season drives the odds/atmosphere (calm at :gilded, chaos at :cascade).
  #   - seed multiple rumors here (the ticker is a rumor firehose).
  npcs: [],
  events: [],
  exits: [
    %Exit{id: "slate_to_throat", to: "bloom_throat"},
    %Exit{id: "slate_to_floor", to: "bloom_floor"},
    %Exit{id: "slate_to_cage", to: "bloom_cage"}
  ]
}
