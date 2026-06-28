alias Shunt.World.Exit

%{
  id: "grayline_cutaway",
  name: "The Cutaway",

  short_description:
    "A service void behind the Tare. Where the work nobody admits to gets done.",

  description:
    "A dead space the original plans left between two structures — a cutaway, the kind of gap that exists only because finishing it would have cost more than leaving it. Someone ran a cable in, set a bench, and made it a workshop. It smells of flux and old coffee. This is where you come when the Court won't make you someone and you've decided to make yourself.",

  tags: [
    :midgrid,
    :latticework
  ],

  graph_position: {1720, -480},

  npcs: [
    "grayline_cal"
  ],

  exits: [
    %Exit{
      id: "cutaway_to_tare",
      to: "grayline_tare"
    }
  ]
}
