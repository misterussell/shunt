alias Shunt.World.Exit

%{
  id: "bloom_slate",
  name: "The Slate",
  short_description: "The betting market on who ascends next — the Bloom's rumor-price ticker.",
  description:
    "A wall of shifting odds and the crowd that lives and dies by them: the Slate takes wagers on who the Spire calls up next, and the numbers move on rumor the way a market moves on news. Read the Slate and you read the whole district's fear.",
  tags: [:midgrid, :gambling, :latticework, :social],
  graph_position: {3210, -1960},
  atmosphere: [
    %{
      requirements: [],
      text:
        "The odds move slow and polite, the crowd murmuring, nobody willing to be the first to bet against a name to its face."
    },
    %{
      requirements: [{:district, "bloom", :season, :>=, :churning}],
      text:
        "The board churns, odds swinging on every rumor that hits the floor, the crowd loud and mean and loving it. Names rise and crater between one breath and the next."
    },
    %{
      requirements: [{:district, "bloom", :season, :>=, :cascade}],
      text:
        "The Slate is a riot. Every name is falling at once, the odds gone meaningless, the crowd screaming at a board that can't reprice fast enough. The whole season has come apart on the floor."
    }
  ],

  # Ghostwork target: the scan layer finds the way into the betting machine's back office;
  # cracking bloom_slate_ice there rewards the ICE-locked rumor (bloom_ascension_ledger) the
  # finale RumorConnection requires — DONE.
  # TODO: :season drives the odds/atmosphere (calm at :gilded, chaos at :cascade); seed additional
  # rumors here via events (the ticker is a rumor firehose); an NPC working the floor.
  lattice: %{
    leads: [
      %{
        id: "slate_back_office",
        requirements: [],
        text:
          "The odds board is a puppet — the numbers come from somewhere behind it. There's a seam into the back office, where the house keeps whatever it prices the wagers off.",
        on_intercept: [{:knowledge, "bloom_slate_ice_found"}]
      }
    ],
    filler: [
      %{
        weight: 3,
        text: "Wager traffic, thick and frantic — bets laid on names you half-recognize.",
        on_intercept: []
      },
      %{
        weight: 2,
        text:
          "An odds-feed handshake, repricing by the second on rumor you can't see the source of.",
        on_intercept: []
      },
      %{
        weight: 1,
        text: "A settled-bet manifest. You skim a loose payout.",
        on_intercept: [{:scrip, 4}]
      }
    ]
  },
  npcs: [],
  events: [],
  exits: [
    %Exit{id: "slate_to_throat", to: "bloom_throat"},
    %Exit{id: "slate_to_floor", to: "bloom_floor"},
    %Exit{id: "slate_to_cage", to: "bloom_cage"}
  ]
}
