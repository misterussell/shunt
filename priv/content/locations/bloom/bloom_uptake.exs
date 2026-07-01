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

  # TODO — the finale, in pieces:
  #   1. ICE node "bloom_uptake_ice" (ice_nodes/bloom/): its reward peels the echo-cover off the
  #      substrate-truth (ascended become ghosts in the Latticework) and grants the ICE-locked
  #      rumor the RumorConnection requires — forcing a full Ghostwork crack.
  #   2. RumorConnection (rumor_connections/bloom_ascent.exs): the resonant rumor set; its
  #      success_event grants "bloom_ascent_clearance" (opens the throat->uptake exit) and the
  #      finale; partial/failure events too.
  #   3. Two-outcome fork events (separate events, each own on_complete — choices carry no effects):
  #        - Ascend: grants "bloom_ascended"; ominous soft-terminus; the Spire seam stays dangling
  #          (no traversable exit up — narrative only, the next content frontier).
  #        - Expose: grants "bloom_throat_starved" (forces :draw -> :slack), "bloom_season_cascade"
  #          (:season -> :cascade), and an Authority heat spike; player stays in the world.
  # No exit up into the Spire — dangling by design (mirrors how the Windlass Anchor Gate dangled
  # up into the Bloom).
  npcs: [],
  events: [],
  exits: [
    %Exit{id: "uptake_to_throat", to: "bloom_throat"}
  ]
}
