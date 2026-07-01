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
  # Finale, all wired: the bloom_ascent RumorConnection's success grants bloom_ascent_clearance
  # (opens throat->uptake and unlocks this node); bloom_uptake_ice grants bloom_truth_substrate;
  # the Ascend/Expose fork events below (gated on bloom_truth_substrate) resolve it. The exit up
  # into the Spire is deliberately dangling — see docs/SHUNT_STORY_CANON.md (Hooks into the Spire).
  npcs: [],
  events: ["bloom_ascend", "bloom_expose"],
  exits: [
    %Exit{id: "uptake_to_throat", to: "bloom_throat"},
    # The up-seam into the Spire, wired to the Winnow (its first district). One-way — a point of no
    # return up out of the harvested Bloom. Two gated exits give OR semantics: whichever Bloom ending
    # resolved, the player climbs the throat to the Winnow's Maw. Spoiled (bloom_ascended: the wire
    # rejected a defective intake) or exposed (bloom_throat_starved: broke in through the jam).
    %Exit{
      id: "uptake_to_winnow_ascended",
      to: "winnow_maw",
      requirements: [{:knows, "bloom_ascended"}],
      travel_text:
        "The throat takes you and, this once, gives you back — spat out the top, spoiled, onto a cold floor at the bottom of the Spire."
    },
    %Exit{
      id: "uptake_to_winnow_exposed",
      to: "winnow_maw",
      requirements: [{:knows, "bloom_throat_starved"}],
      travel_text:
        "You climb the jammed throat you broke, up past where the harvest stopped, into the Spire through the door you shut."
    }
  ]
}
