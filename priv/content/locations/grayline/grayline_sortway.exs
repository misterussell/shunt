alias Shunt.World.Exit

%{
  id: "grayline_sortway",
  name: "The Sortway",

  short_description:
    "Where the side door lets out. Midgrid's intake margin, off the books.",

  description:
    "Not the concourse. A low service corridor that used to sort arrivals by paper — the floor still carries the painted lanes, worn to ghosts. The turnstiles are one wall over and a world away. Here the light is borrowed off a cracked panel, the air still smells faintly of the lift, and people stand the way you stand when you've gotten somewhere and don't yet know if you're allowed to be there.",

  tags: [
    :midgrid,
    :transit
  ],

  graph_position: {1500, -260},

  npcs: [
    "grayline_della"
  ],

  exits: [
    %Exit{
      id: "sortway_to_upper_landing",
      to: "liftworks_upper_landing"
    },
    %Exit{
      id: "sortway_to_tare",
      to: "grayline_tare"
    }
  ]
}
