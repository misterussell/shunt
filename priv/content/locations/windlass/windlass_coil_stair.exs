alias Shunt.World.Exit

%{
  id: "windlass_coil_stair",
  name: "The Coil Stair",

  short_description:
    "The service spine winding up through every turn of the Windlass.",

  description:
    "A steel stair bolted to the inside of the coil, spiralling up past every turn of the city — Slagfoot below, the Fitworks and the market above, and High Anchor somewhere up in the haze where the lamps run cleaner. Everyone uses it and nobody owns it, which in the Windlass makes it the closest thing to neutral ground. The higher the stair climbs, the more Authority readers you pass, and the less anyone meets your eye.",

  tags: [
    :midgrid,
    :transit
  ],

  graph_position: {2600, -1040},

  atmosphere: [
    %{requirements: [], text: "The stair hums with the district's traffic and the low static of readers watching it. You climb, and the readers count you, turn by turn."},
    %{requirements: [{:district, "windlass", :grid, :>=, :contested}], text: "Some of the readers hang dark now, spliced or spoofed, and the people on the stair move a little freer past the blind ones. The war is on the walls."}
  ],

  events: [],

  exits: [
    %Exit{
      id: "coil_stair_to_landing",
      to: "windlass_slagfoot_landing"
    },
    %Exit{
      id: "coil_stair_to_fitters_floor",
      to: "windlass_fitters_floor"
    },
    %Exit{
      id: "coil_stair_to_coil_market",
      to: "windlass_coil_market"
    },
    %Exit{
      id: "coil_stair_to_high_anchor",
      to: "windlass_high_anchor"
    }
  ]
}
