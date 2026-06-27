alias Shunt.World.Exit

%{
  id: "crossgate_counting_house",
  name: "The Counting House",

  short_description:
    "Where the Syndicate's books are kept. Numbers don't lie.",

  description:
    "A secondary room off the administrative block — smaller, quieter. Ledgers, data cores, a terminal running on isolated power. The Syndicate's financial nerve center for The Crossgate: every scrip in, every cut taken, every debt owed. The ICE protecting the ledger is the most current thing in this building.",

  tags: [
    :syndicate,
    :restricted
  ],

  graph_position: {1200, 530},

  lattice: %{
    leads: [
      %{
        id: "counting_house_ledger_signal",
        requirements: [],
        text:
          "A Syndicate financial node — ice_security spec, running on isolated power. The ledger is right there if you can get through it.",
        on_intercept: [{:knowledge, "crossgate_counting_house_ledger_found"}]
      }
    ],
    filler: [
      %{
        weight: 3,
        text: "The isolated power loop blocks most signals. Nothing readable.",
        on_intercept: []
      }
    ]
  },

  exits: [
    %Exit{
      id: "counting_house_to_house",
      to: "crossgate_house_of_closed_hands"
    }
  ]
}
