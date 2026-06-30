alias Shunt.World.Exit

%{
  id: "shunt9_food_stalls",
  name: "Food Stalls",

  short_description:
    "Grease smoke and shouted orders fill the narrow row.",

  description:
    "Vendors work woks and grills shoulder to shoulder, serving whatever the yard and the relay traps have turned up that day.",

  tags: [
    :market,
    :social
  ],

  graph_position: {250, 570},

  lattice: %{
    leads: [],
    filler: [
      %{
        weight: 3,
        text: "Order chatter and the hiss of woks drowns the channel. People here talk with their mouths, not their decks.",
        on_intercept: []
      },
      %{
        weight: 2,
        text: "A vendor's tab-reader leaks a few stray credit fragments onto the open feed.",
        on_intercept: [{:scrip, 2}]
      },
      %{
        weight: 2,
        text: "Snatches of gossip riding a cheap comm — debts, grudges, who's short on supply this week.",
        on_intercept: []
      }
    ]
  },

  npcs: [
    "shunt9_food_stalls_dex",
    "shunt9_food_stalls_ladle"
  ],

  events: [
    "shunt9_food_stalls_vendor_board"
  ],

  exits: [
    %Exit{
      id: "food_stalls_to_bazaar",
      to: "shunt9_bazaar"
    },
    %Exit{
      id: "food_stalls_to_cold_store",
      to: "shunt9_cold_store"
    }
  ]
}
