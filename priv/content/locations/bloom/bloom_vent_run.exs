alias Shunt.World.Exit

%{
  id: "bloom_vent_run",
  name: "The Vent Run",
  short_description:
    "The sooty duct spine behind the petals — the gilt's ugly underside, walkable.",
  description:
    "Behind the drapery of every petal runs the vent spine: soot-black ducts, groaning when the Spire dumps heat, threaded with the maintenance runs nobody's supposed to use. It's the one place in the Bloom that doesn't pretend, and the one route the Authority doesn't watch.",
  tags: [:midgrid, :infrastructure, :latticework],
  graph_position: {3040, -1850},

  # TODO — Street Alchemy engine + the back-route hub:
  #   - exhaust-duct repairables (repairables/bloom_*.exs, e.g. "bloom_intake_duct") whose
  #     "patched"/"repaired" states drive the district :draw fact (wire the ids back into
  #     districts/bloom.exs :draw rules). This is the wealth loop's engine.
  #   - the unwatched back-route linking the petal-backs (already wired: afterburn, reclaim,
  #     galley, cage) and the Junction.
  #   - pocket-of-C atmosphere; optional Street Alchemy fixer NPC.
  npcs: [],
  events: [],
  exits: [
    %Exit{id: "vent_run_to_afterburn", to: "bloom_afterburn"},
    %Exit{id: "vent_run_to_reclaim", to: "bloom_reclaim"},
    %Exit{id: "vent_run_to_galley", to: "bloom_galley"},
    %Exit{id: "vent_run_to_cage", to: "bloom_cage"},
    %Exit{id: "vent_run_to_junction", to: "bloom_junction"}
  ]
}
