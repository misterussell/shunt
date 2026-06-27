alias Shunt.World.Exit

%{
  id: "shunt9_scrap_yard",
  name: "Scrap Yard",

  short_description:
    "Mountains of twisted metal loom overhead.",

  description:
    "Stripped chassis and dead drones are stacked in rusting heaps, picked over by scavvers with magnet rigs and cutting torches.",

  tags: [
    :salvage,
    :underbelly
  ],

  graph_position: {250, 230},

  events: [
    "shunt9_scrap_yard_watchman"
  ],

  exits: [
    %Exit{
      id: "scrap_yard_to_bazaar",
      to: "shunt9_bazaar"
    }
  ]
}
