alias Shunt.World.Exit

%{
  id: "windlass_anchor_gate",
  name: "The Anchor Gate",

  short_description:
    "The ascent from the Windlass to the last district before the Spire.",

  description:
    "Past the Ascent Office, where the cable anchors, a single lift-shaft climbs out of the Windlass toward the district above — the last of the Midgrid before the Spire. From here the coil is just a machine you climbed, and the way on is a door with the Authority's hand on it. It opens for permits, for freight, for people the grid has decided are finished with this place. Standing under it, you can feel how close the top has become, and how much closer it isn't yet.",

  tags: [
    :midgrid,
    :transit
  ],

  graph_position: {2680, -1500},

  events: [
    "windlass_ascent"
  ],

  exits: [
    %Exit{
      id: "anchor_gate_to_high_anchor",
      to: "windlass_high_anchor"
    },
    # Up into the Bloom — the last district before the Spire. Opens once the player has taken the
    # Windlass ascent (windlass_ascent grants windlass_ascended). Return exit is on bloom_rimwalk.
    %Exit{
      id: "anchor_gate_to_bloom",
      to: "bloom_rimwalk",
      requirements: [{:knows, "windlass_ascended"}],
      travel_text: "The lift climbs out of the coil and into the light of the Bloom."
    }
  ]
}
