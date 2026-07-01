alias Shunt.World.Exit

%{
  id: "windlass_high_anchor",
  name: "High Anchor",

  short_description:
    "The top turn, where the cable anchors and the permitted live.",

  description:
    "The summit of the coil, where the great cable anchors into the Spire-side rock and the lamps finally run clean. Up here the Windlass stops being a machine and starts pretending to be a city — quiet residences, swept walks, residents with permits and three dull years of clean record apiece. They do not look down the coil at where their power and their freight come from. The next ascent is right here, above them, and they live in the shadow of a door most of them will never be allowed through either.",

  tags: [
    :midgrid,
    :residential,
    :social
  ],

  graph_position: {2600, -1360},

  atmosphere: [
    %{requirements: [], text: "The Authority's grip is tightest here, so gentle you could mistake it for order. Everyone is permitted and everyone is watched and nobody says so."},
    %{requirements: [{:district, "windlass", :grid, :>=, :contested}], text: "Even High Anchor feels it now — a reader dark here, a permit-check skipped there. The permitted glance at each other like people who've realized the walls might be listening after all."}
  ],

  npcs: [
    "windlass_prim"
  ],

  events: [
    "windlass_prim_intro"
  ],

  exits: [
    %Exit{
      id: "high_anchor_to_coil_stair",
      to: "windlass_coil_stair"
    },
    %Exit{
      id: "high_anchor_to_ascent_office",
      to: "windlass_ascent_office"
    },
    %Exit{
      id: "high_anchor_to_anchor_gate",
      to: "windlass_anchor_gate"
    }
  ]
}
