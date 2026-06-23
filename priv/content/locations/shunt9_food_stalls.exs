%{
  key: "shunt9_food_stalls",
  name: "Food Stalls",

  short_description:
    "Grease smoke and shouted orders fill the narrow row.",

  description:
    "Vendors work woks and grills shoulder to shoulder, serving whatever the yard and the relay traps have turned up that day.",

  tags: [
    :market,
    :social
  ],

  graph_position: {700, 300},

  # TODO: alias Shunt.World.Exit and convert the map below to %Exit{to: ...},
  # dropping requirements: [] (matches the struct default).
  exits: [
    %{to: "shunt9_bazaar", requirements: []}
  ]
}
