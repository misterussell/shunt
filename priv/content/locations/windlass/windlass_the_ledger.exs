alias Shunt.World.Exit

%{
  id: "windlass_the_ledger",
  name: "The Ledger",

  short_description:
    "The Syndicate's corner of the market, where debts are the real currency.",

  description:
    "A quiet booth off the market floor where the Syndicate of Closed Hands keeps its accounts. There's no goods on display here, only the understanding that everyone in the Windlass owes someone, and that the Syndicate holds most of the paper. They fence what won't fence clean elsewhere and they lend against what you'd rather not name. What they trade in, mostly, is knowing who's short — which on these turns is worth more than scrip.",

  tags: [
    :midgrid,
    :market,
    :social
  ],

  graph_position: {2960, -1200},

  npcs: [
    "windlass_sable"
  ],

  events: [
    "windlass_sable_intro"
  ],

  exits: [
    %Exit{
      id: "the_ledger_to_coil_market",
      to: "windlass_coil_market"
    }
  ]
}
