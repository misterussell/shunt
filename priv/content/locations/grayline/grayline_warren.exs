alias Shunt.World.Exit

%{
  id: "grayline_warren",
  name: "The Warren",

  short_description:
    "Where the hollows sleep. Midgrid's old staff block, taken over and patched.",

  description:
    "A residential stack the grid decommissioned and never reclaimed — corridors of bunkrooms with the corporate signage scraped off and the doors re-hung by hand. Power comes off an unlicensed tap somebody bridged into the Midgrid main. Heat exchangers tick. Wash-water gets carried in. People live here the way people live anywhere they aren't supposed to: carefully, and together, and ready to go quiet when boots come through.",

  tags: [
    :midgrid,
    :social
  ],

  graph_position: {1600, -150},

  exits: [
    %Exit{
      id: "warren_to_tare",
      to: "grayline_tare"
    }
  ]
}
