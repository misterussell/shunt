alias Shunt.World.Exit

%{
  id: "bloom_throat",
  name: "The Throat",
  short_description:
    "The hub concourse where every duct meets the Spire's underside — the Bloom's best address.",
  description:
    "The throat of the flower, where all four petals open onto the Spire's underside and the ascent gate. The most prestigious ground in the Midgrid, and the most watched: the Authority keeps the throat, because the throat keeps the way up.",
  tags: [:midgrid, :social, :transit],
  graph_position: {3000, -2100},
  atmosphere: [
    %{
      requirements: [],
      text:
        "The throat runs cold and half-lit, the great vents above breathing slow. Even the Authority's readers seem to be conserving what little the Spire's giving down."
    },
    %{
      requirements: [{:district, "bloom", :draw, :>=, :drawing}],
      text:
        "The throat's come up warm and bright, the vents pulling steady, the concourse loud with people performing that they were always meant to stand this close to the top."
    },
    %{
      requirements: [{:district, "bloom", :draw, :>=, :gorging}],
      text:
        "The throat roars. The Spire pours down through it in a flood of heat and light, the whole concourse blazing — and the ascent gate above swallows another name, and another, faster than anyone down here lets themselves count."
    }
  ],
  npcs: ["bloom_aurel"],
  events: [],
  exits: [
    %Exit{id: "throat_to_rimwalk", to: "bloom_rimwalk"},
    # The way up. Gated on the finale: the player only reaches the Uptake once the case is cracked
    # and they hold ascent clearance.
    # Opens once the case cracks: bloom_ascent_success grants bloom_ascent_clearance.
    %Exit{
      id: "throat_to_uptake",
      to: "bloom_uptake",
      requirements: [{:knows, "bloom_ascent_clearance"}]
    },
    %Exit{id: "throat_to_burnoff", to: "bloom_burnoff"},
    %Exit{id: "throat_to_gilt_row", to: "bloom_gilt_row"},
    %Exit{id: "throat_to_spread", to: "bloom_spread"},
    %Exit{id: "throat_to_slate", to: "bloom_slate"}
  ]
}
