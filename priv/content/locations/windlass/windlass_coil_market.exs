alias Shunt.World.Exit

%{
  id: "windlass_coil_market",
  name: "Coil Market",

  short_description:
    "The great market on the mid-turns, where the whole city trades.",

  description:
    "Three turns of the coil opened out into one long market, stalls stacked up the inner wall and goods moving in every direction at once. Everything the Windlass makes, steals, or smuggles passes through here, and everything is watched — the Authority's readers priced into every transaction, the Syndicate of Closed Hands pricing in everything the readers miss. It is loud, rich, and entirely owned. Nothing on these turns moves free.",

  tags: [
    :midgrid,
    :market,
    :social,
    :latticework
  ],

  graph_position: {2760, -1120},

  atmosphere: [
    %{requirements: [], text: "Every stall runs its transactions through the Authority's readers, and the readers take their cut in knowing. Prices here include the cost of being seen."},
    %{requirements: [{:district, "windlass", :grid, :>=, :contested}], text: "Whole rows of stalls trade off-reader now, quietly, while the Authority's channels flicker. The market's found a second set of prices for people the grid can't watch."}
  ],

  # The commerce registry — the Authority's read on every deal — runs a node here.
  lattice: %{
    leads: [
      %{
        id: "market_registry_signal",
        requirements: [],
        text: "Every transaction on the floor pings the same registry node. It's fat, slow, and full of things the Authority would rather you didn't correlate.",
        on_intercept: [{:knowledge, "windlass_market_registry_found"}]
      }
    ],
    filler: [
      %{weight: 3, text: "Price feeds and reader handshakes, thick as flies.", on_intercept: []},
      %{weight: 2, text: "A skimmed transaction fragment resolves into loose scrip.", on_intercept: [{:scrip, 4}]}
    ]
  },

  events: [
    "windlass_coil_market_scene"
  ],

  exits: [
    %Exit{
      id: "coil_market_to_coil_stair",
      to: "windlass_coil_stair"
    },
    %Exit{
      id: "coil_market_to_the_ledger",
      to: "windlass_the_ledger"
    },
    %Exit{
      id: "coil_market_to_the_skim",
      to: "windlass_the_skim"
    }
  ]
}
