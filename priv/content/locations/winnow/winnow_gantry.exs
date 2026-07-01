alias Shunt.World.Exit

%{
  id: "winnow_gantry",
  name: "The Gantry",
  short_description:
    "The wardens' overwatch — and the sealed door none of them will look at.",
  description:
    "The catwalk over the whole Floor, where the wardens stand and run the Winnow. From up here the three lines make sense: intake, sort, dispatch, a machine for turning people into the thing the Spire runs on. The wardens keep it moving and keep their heads down, because at the far end of the Gantry there's a door they didn't build and don't hold the key to, and the quota comes out of it. They run the top of the Spire's first district and they are afraid of the wall behind them. That should tell you everything about who's actually on top.",
  tags: [:spire, :authority, :latticework],
  graph_position: {3000, -2860},
  atmosphere: [
    %{
      requirements: [],
      text:
        "The wardens work the catwalk correct and incurious, moving the lines along, careful never to face the sealed door at the Gantry's end for longer than it takes to read the number off it."
    },
    %{
      requirements: [{:district, "winnow", :quota, :>=, :culling}],
      text:
        "The wardens are pushing the lines past what the load can bear, and they know it, and they do it anyway, because the alternative is being on the wrong side of that door when the number comes up short. Fear runs downhill here. It starts at the wall."
    }
  ],
  npcs: ["winnow_halden"],
  events: [],
  exits: [
    %Exit{id: "gantry_to_tally", to: "winnow_tally"},
    # The sealed door opens only once the case is cracked — the player has proven the quota comes
    # from above the Authority (winnow_tier_above, granted by the investigation's success event).
    %Exit{
      id: "gantry_to_vestibule",
      to: "winnow_vestibule",
      requirements: [{:knows, "winnow_tier_above"}],
      travel_text: "The sealed door reads what you've learned and, for the first time, opens."
    }
  ]
}
