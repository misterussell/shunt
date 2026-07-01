alias Shunt.World.Exit

%{
  id: "winnow_reclaim",
  name: "The Reclaim Bench",
  short_description:
    "Where the caste strips the culled — augments off the empty, before the wire takes the rest.",
  description:
    "A row of benches under bad light where the caste pulls anything worth keeping off the culled before the belt carries the bodies down. Chrome, ports, a good shunt worth reseating — reclaimed, logged, and mostly skimmed. It's the grimmest work on the Floor and the caste fights over it, because the reclaim line is the one place the wardens don't weigh too closely, and a person can bank a little of their own here. The ones who work the benches longest stop flinching. That's its own kind of warning.",
  tags: [:spire, :salvage, :latticework],
  graph_position: {2760, -2700},
  atmosphere: [
    %{
      requirements: [],
      text:
        "The benches are worked in silence, hands moving out of habit, nobody looking too long at whose chrome they're pulling."
    },
    %{
      requirements: [{:district, "winnow", :waking, :>=, :stirring}],
      text:
        "The benches have gone quiet in a different way — the caste working slower, setting things aside, a few of them lately unable to strip a face without knowing the name that went with it. It's harder to do this work awake."
    }
  ],
  npcs: [
    "winnow_tithe",
    %{id: "winnow_leda", requirements: [{:district, "winnow", :waking, :>=, :stirring}]}
  ],
  events: [],
  exits: [
    %Exit{id: "reclaim_to_cull", to: "winnow_cull_line"},
    %Exit{id: "reclaim_to_sorting", to: "winnow_sorting_floor"}
  ]
}
