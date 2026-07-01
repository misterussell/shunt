alias Shunt.World.Exit

%{
  id: "winnow_cull_line",
  name: "The Cull Line",
  short_description:
    "The left belt — where whatever the winnow rejects goes down to the wire.",
  description:
    "The belt that runs the wrong way. Everything the Sorting Floor shoves left ends up here, carried down a throat narrower and darker than the one it came up, to the wire that finishes what the Bloom's shunt started. They don't call it killing because nothing dies — the body goes on, empty, and the mind goes into the Latticework as substrate. Spoiled goods get culled the same as fresh. The only mercy on the Cull Line is that it's quiet, and it's fast.",
  tags: [:spire, :infrastructure, :latticework],
  graph_position: {2860, -2600},
  atmosphere: [
    %{
      requirements: [],
      text:
        "The belt runs slow and mostly empty — a spoiled arrival now and then, a clean cull, the wire humming patient at the bottom of the dark."
    },
    %{
      requirements: [{:district, "winnow", :quota, :>=, :culling}],
      text:
        "The belt is loaded and it isn't all spoiled goods anymore. When the number can't be met from below, it gets met from the line — winnowers who came up this same throat, sorted onto their own belt to make a quota that was written somewhere they'll never see. The wire doesn't ask which is which."
    }
  ],
  npcs: [
    "winnow_mira",
    %{id: "winnow_bram", requirements: [{:district, "winnow", :quota, :>=, :culling}]}
  ],
  events: [],
  exits: [
    %Exit{id: "cull_to_maw", to: "winnow_maw"},
    %Exit{id: "cull_to_sorting", to: "winnow_sorting_floor"},
    %Exit{id: "cull_to_reclaim", to: "winnow_reclaim"}
  ]
}
