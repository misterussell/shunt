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

  npcs: [
    "shunt9_food_stalls_dex"
  ],

  exits: [
    %Exit{
      id: "food_stalls_to_bazaar",
      to: "shunt9_bazaar"
    }
  ]
}
