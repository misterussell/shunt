%{
  key: "shunt9_scrap_yard",
  name: "Scrap Yard",

  short_description:
    "Mountains of twisted metal loom overhead.",

  description:
    "Stripped chassis and dead drones are stacked in rusting heaps, picked over by scavvers with magnet rigs and cutting torches.",

  tags: [
    :salvage,
    :underbelly
  ],

  graph_position: {300, 300},

  # TODO: alias Shunt.World.Exit and convert the map below to %Exit{to: ...},
  # dropping requirements: [] (matches the struct default).
  exits: [
    %{to: "shunt9_bazaar", requirements: []}
  ]
}
