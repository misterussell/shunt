alias Shunt.World.Exit

%{
  id: "windlass_fitters_floor",
  name: "Fitters' Floor",

  short_description:
    "The engineering turn — fabrication benches, relay work, and the Collective's public face.",

  description:
    "A long turn of the coil given over to benches: fitters winding relays, patching decks, and fabricating the parts the rest of the district can't buy clean. It's the most useful floor in the Windlass and everyone knows it, which is why the Authority's readers cluster thick here and the real work happens behind them. The Latticework Collective runs this floor the way a union runs a shop — quietly, completely, and never in writing.",

  tags: [
    :midgrid,
    :engineering,
    :latticework,
    :social
  ],

  graph_position: {2340, -980},

  atmosphere: [
    %{requirements: [], text: "The benches work under the readers' eyes, careful and slow. Every fitter here can feel the Authority counting their hands."},
    %{requirements: [{:district, "windlass", :grid, :>=, :contested}], text: "The readers over the benches flicker and lie now. The fitters work faster, louder, the way people do when they've stopped believing they're being watched."},
    %{requirements: [{:district, "windlass", :grid, :>=, :open}], text: "The floor runs wide open, decks and relays trading hands in plain sight. For the first time the Fitworks looks like what it is: the part of the Windlass that actually runs the Windlass."}
  ],

  # The Latticework here carries the Authority's relay traffic — scanning finds the way into a
  # Fitworks control node.
  lattice: %{
    leads: [
      %{
        id: "fitworks_relay_signal",
        requirements: [],
        text: "Under the bench-chatter runs a hard Authority channel — a relay node routing half the floor's readers. There's a seam in it.",
        on_intercept: [{:knowledge, "windlass_fitworks_ice_found"}]
      }
    ],
    filler: [
      %{weight: 3, text: "Reader handshakes, endless and dull, counting hands on the floor.", on_intercept: []},
      %{weight: 2, text: "A fitter's private channel, complaining about the Authority in terms you file away.", on_intercept: []},
      %{weight: 1, text: "A stray parts-manifest fragment. You skim a few credits' worth of nothing.", on_intercept: [{:scrip, 3}]}
    ]
  },

  npcs: [
    "windlass_fuse"
  ],

  events: [
    "windlass_fuse_intro"
  ],

  exits: [
    %Exit{
      id: "fitters_floor_to_coil_stair",
      to: "windlass_coil_stair"
    },
    # The Collective doesn't open the Coldroom to strangers. Fuse vouches you in.
    %Exit{
      id: "fitters_floor_to_coldroom",
      to: "windlass_coldroom",
      requirements: [{:knows, "windlass_fuse_vouched"}],
      travel_text: "A fitter you've never spoken to holds a panel open without looking at you. Fuse's word travels ahead of you."
    },
    # Your Loft, once the Collective sets you up in it.
    %Exit{
      id: "fitters_floor_to_winders_loft",
      to: "windlass_winders_loft",
      requirements: [{:knows, "windlass_loft_offered"}]
    }
  ]
}
