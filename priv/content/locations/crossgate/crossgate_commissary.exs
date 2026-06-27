alias Shunt.World.Exit

%{
  id: "crossgate_commissary",
  name: "The Commissary",

  short_description:
    "A proper store. Stocked shelves, a counter, no haggling.",

  description:
    "A converted waiting room running as a general supply store. The shelves are bolted to the original wall brackets and stocked with goods you'd actually need — not the stripped-down surplus that passes for stock in Shunt 9's stalls. There's a counter, a proprietor behind it, and a posted price list. No negotiation.",

  tags: [
    :market,
    :underbelly
  ],

  graph_position: {900, 80},

  npcs: [
    "crossgate_commissary_hest"
  ],

  exits: [
    %Exit{
      id: "commissary_to_concourse",
      to: "crossgate_concourse"
    },
    %Exit{
      id: "commissary_to_the_register",
      to: "crossgate_the_register"
    }
  ]
}
