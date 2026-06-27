alias Shunt.World.Exit

%{
  id: "crossgate_relay_block",
  name: "Relay Block",

  short_description:
    "The interchange's power and communications hub. Contested.",

  description:
    "A fortified infrastructure room housing the interchange's original power distribution and communications relay equipment. The Syndicate wants it locked down. The Latticework Collective has already been in twice. The current arrangement is an uneasy shared access that neither side admits to.",

  tags: [
    :infrastructure,
    :restricted
  ],

  graph_position: {1200, 380},

  lattice: %{
    leads: [
      %{
        id: "relay_block_node_signal",
        requirements: [],
        text:
          "A Latticework Collective node — live, heavily masked, sitting inside the relay infrastructure like it belongs there.",
        on_intercept: [{:knowledge, "crossgate_relay_block_node_found"}]
      }
    ],
    filler: [
      %{
        weight: 3,
        text: "Syndicate comm traffic — encrypted, unreadable without a key you don't have.",
        on_intercept: []
      },
      %{
        weight: 2,
        text: "A stray Collective data fragment catches on your deck. Worth a few scrip.",
        on_intercept: [{:scrip, 4}]
      }
    ]
  },

  events: [
    "crossgate_relay_block_interference"
  ],

  exits: [
    %Exit{
      id: "relay_block_to_concourse",
      to: "crossgate_concourse"
    },
    %Exit{
      id: "relay_block_to_cold_storage",
      to: "crossgate_cold_storage"
    },
    %Exit{
      id: "relay_block_to_lower_concourse",
      to: "crossgate_lower_concourse"
    }
  ]
}
