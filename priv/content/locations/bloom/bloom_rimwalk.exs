alias Shunt.World.Exit

%{
  id: "bloom_rimwalk",
  name: "The Rimwalk",
  short_description: "Where the Windlass cable lands you on the outer rim of the Bloom.",
  description:
    "You step off the anchor lift onto the outer rim of the Bloom — the Spire's exhaust-flower splayed under its underside, every petal blazing with borrowed light and warmth that pools here for free. The Authority reads you before you've caught your breath.",
  tags: [:midgrid, :transit, :social],
  graph_position: {3000, -1620},

  # bloom_arrival (the POI event) establishes the Bloom + the ascent premise at entry.
  # TODO (optional flavor): atmosphere tiers on :draw; an Authority reader NPC for the first read.
  npcs: [],
  events: ["bloom_arrival"],
  exits: [
    %Exit{id: "rimwalk_to_throat", to: "bloom_throat"},
    # Return down the anchor to the Windlass (the up-exit is authored on windlass_anchor_gate).
    %Exit{
      id: "rimwalk_to_windlass_anchor_gate",
      to: "windlass_anchor_gate",
      travel_text: "The anchor lift drops you back down the coil, out of the light."
    }
  ]
}
