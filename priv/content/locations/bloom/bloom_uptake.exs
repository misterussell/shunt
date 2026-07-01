alias Shunt.World.Exit

%{
  id: "bloom_uptake",
  name: "The Uptake",
  short_description:
    "The ascent gate itself — the throat's mouth, and the way up into the Spire.",
  description:
    "The uptake: the flue that carries the Bloom's heat up into the Spire, and the door the whole district claws toward. Stand here holding clearance and you can feel how close the top is. What nobody standing here knows is what waits on the other side of going up.",
  tags: [:midgrid, :transit, :latticework],
  graph_position: {3000, -2340},

  # ICE node "bloom_uptake_ice" (ice_nodes/bloom/): the finale hack, gated on bloom_ascent_clearance;
  # its deepest layer reward grants "bloom_truth_substrate" (peels the echo-cover off the
  # substrate-truth — ascended become ghosts in the Latticework) — DONE.
  # TODO — the rest of the finale:
  #   1. RumorConnection (rumor_connections/bloom_ascent.exs): the resonant rumor set (incl. the
  #      ICE-locked bloom_ascension_ledger); its success_event grants "bloom_ascent_clearance"
  #      (opens throat->uptake AND unlocks bloom_uptake_ice); partial/failure events too.
  #   2. Two-outcome fork events, gated on {:knows,"bloom_truth_substrate"} (separate events, each
  #      own on_complete — choices carry no effects):
  #        - Ascend: grants "bloom_ascended"; ominous soft-terminus; Spire seam stays dangling
  #          (no traversable exit up — narrative only, the next content frontier).
  #        - Expose: grants "bloom_throat_starved" (forces :draw -> :slack), "bloom_season_cascade"
  #          (:season -> :cascade), and an Authority heat spike; player stays in the world.
  # No exit up into the Spire — dangling by design (mirrors how the Windlass Anchor Gate dangled
  # up into the Bloom).
  npcs: [],
  events: ["bloom_ascend", "bloom_expose"],
  exits: [
    %Exit{id: "uptake_to_throat", to: "bloom_throat"}
  ]
}
