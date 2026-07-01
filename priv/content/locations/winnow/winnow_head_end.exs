alias Shunt.World.Exit

%{
  id: "winnow_head_end",
  name: "The Head-End",
  short_description:
    "The top of the Winnow — where the way on into the Spire begins, and doesn't open yet.",
  description:
    "The channel from the Vestibule climbs to a landing at the top of the district, where the Winnow ends and the real Spire begins. From here you can see it — tier on tier of it going up, the whole vertical world you climbed built to feed this, and somewhere above the Authority a thing that eats what the throat sends and writes the quota that keeps it fed. You got the first honest look anyone from below has ever had at the top. The way up is right there. It is not open yet. But you know now that it's there, and what it costs, and who's really at the end of it.",
  tags: [:spire, :transit, :latticework],
  graph_position: {3000, -3120},

  # The Winnow's finale beat: winnow_ascension_glimpse (gated on winnow_shunt_complete) delivers the
  # tier-above payoff and sets winnow_ascended — the forward flag the NEXT Spire district reads.
  # The up-seam into the Spire is deliberately dangling (no traversable exit yet), mirroring how
  # bloom_uptake dangled up into the Winnow. See docs/SHUNT_STORY_CANON.md (Hooks into the Spire).
  npcs: [],
  events: ["winnow_ascension_glimpse"],
  exits: [
    %Exit{id: "head_end_to_vestibule", to: "winnow_vestibule"}
  ]
}
