alias Shunt.World.Exit

%{
  id: "grayline_glassline",
  name: "The Glassline",

  short_description:
    "The clean edge. Where the Grayline ends and Midgrid proper begins.",

  description:
    "A wall of ad-glass and turnstiles, and past them the Midgrid you were promised — wide, lit, certain of itself, full of people the readers wave through without a glance. The line is the readers. They don't check your face; they check whether the grid remembers you. Stand here long enough and a watchman will notice you noticing. The way on is open to anyone the registry can vouch for, which is everyone on that side and no one on this.",

  tags: [
    :midgrid,
    :transit
  ],

  graph_position: {1880, -230},

  events: [
    "grayline_glassline_turned_back",
    "grayline_glassline_through"
  ],

  exits: [
    %Exit{
      id: "glassline_to_tare",
      to: "grayline_tare"
    },
    %Exit{
      id: "glassline_to_holdover",
      to: "grayline_holdover"
    }
  ]
}
