alias Shunt.World.Exit

%{
  id: "crossgate_the_drop",
  name: "The Drop",

  short_description:
    "No sign. The right door if you know to look.",

  description:
    "A narrow room off the west platform's service corridor, behind an unmarked door that doesn't appear on any map of The Crossgate. Weapons, contraband, items with complicated histories — sold at prices that reflect the risk of knowing where to find them.",

  tags: [
    :market,
    :underbelly,
    :restricted
  ],

  requirements: [
    {:knows, "crossgate_the_drop_location"}
  ],

  graph_position: {1200, 150},

  exits: [
    %Exit{
      id: "the_drop_to_west_platform",
      to: "crossgate_west_platform"
    }
  ]
}
