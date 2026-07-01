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

  # Street Alchemy engine: the bloom_intake_duct + bloom_flare_manifold repairables live here
  # (surfaced automatically by location_id) and drive the district :draw fact — DONE.
  # TODO: atmosphere tiers on :draw (the spine ticks louder / the ducts sing with heat as the
  # Spire pulls harder); optional Street Alchemy fixer NPC who trades in duct-work.
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
