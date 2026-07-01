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

  # TODO: Authority presence here (the ascent officer NPC who decides who's "listed"); atmosphere
  # tiers on :draw (the throat brightens/roars as the Spire pulls harder); this is the watched
  # front-route hub radiating to all four petals. The ascent-clearance framing lives here.
  npcs: ["bloom_aurel"],
  events: [],
  exits: [
    %Exit{id: "throat_to_rimwalk", to: "bloom_rimwalk"},
    # The way up. Gated on the finale: the player only reaches the Uptake once the case is cracked
    # and they hold ascent clearance.
    # TODO: confirm "bloom_ascent_clearance" is the flag granted by the RumorConnection success
    # event (see bloom_uptake TODO).
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
