alias Shunt.World.Exit

%{
  key: "shunt9_bazaar",
  name: "Shunt 9 Bazaar",

  short_description:
    "The beating heart of Shunt 9.",

  description:
    "Hundreds of stalls crowd the abandoned transit platform, lit by salvaged work lamps and the glow of a dozen black-market terminals.",

  tags: [
    :market,
    :underbelly
  ],

  graph_position: {500, 300},

  exits: [
    %Exit{to: "shunt9_scrap_yard"},
    %Exit{to: "shunt9_food_stalls"},
    %Exit{to: "shunt9_power_relay"},
    %Exit{to: "shunt9_burned_platform"}
  ]
}
