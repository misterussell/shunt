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
  atmosphere: [
    %{
      requirements: [],
      text:
        "The spine sits cold and choked, the ducts furred with dead soot, the dampers seized. Behind the petals' drapery the Bloom is just cold iron and old smoke."
    },
    %{
      requirements: [{:district, "bloom", :draw, :>=, :drawing}],
      text:
        "The ducts tick and pull now, heat moving through them uneven, the spine working again. It's warmer back here than it's been in a long time, and a good deal louder."
    },
    %{
      requirements: [{:district, "bloom", :draw, :>=, :gorging}],
      text:
        "The spine sings — every duct wide open and pouring, the manifold breathing even, heat rolling off the iron in waves. The Bloom runs on this, all of it, and back here you can hear exactly how hard."
    }
  ],

  # Street Alchemy engine: the bloom_intake_duct + bloom_flare_manifold repairables live here
  # (surfaced automatically by location_id) and drive the district :draw fact — DONE.
  # TODO: atmosphere tiers on :draw (the spine ticks louder / the ducts sing with heat as the
  # Spire pulls harder); optional Street Alchemy fixer NPC who trades in duct-work.
  npcs: ["bloom_soot"],
  events: [],
  exits: [
    %Exit{id: "vent_run_to_afterburn", to: "bloom_afterburn"},
    %Exit{id: "vent_run_to_reclaim", to: "bloom_reclaim"},
    %Exit{id: "vent_run_to_galley", to: "bloom_galley"},
    %Exit{id: "vent_run_to_cage", to: "bloom_cage"},
    %Exit{id: "vent_run_to_junction", to: "bloom_junction"}
  ]
}
