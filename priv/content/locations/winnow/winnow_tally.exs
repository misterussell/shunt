alias Shunt.World.Exit

%{
  id: "winnow_tally",
  name: "The Tally",
  short_description:
    "The quota office — where the number gets posted and the caste reads its own odds.",
  description:
    "A glassed booth over the Floor where the day's quota gets posted and the running count ticks against it. The caste can't help reading it — the gap between the number and the count is the gap between a normal shift and a cull, and everyone on the belt does that arithmetic all day. The wardens post the quota; they don't set it. Watch the booth long enough and you'll see even the wardens flinch when the new number comes down, because it comes down from somewhere none of them will point at.",
  tags: [:spire, :social, :latticework],
  graph_position: {3140, -2820},
  atmosphere: [
    %{
      requirements: [],
      text:
        "The count runs a little under the number, the way it always does, the booth quiet with the ordinary dread of people hoping the gap closes before end of shift."
    },
    %{
      requirements: [{:district, "winnow", :quota, :>=, :culling}],
      text:
        "The number on the glass is impossible and everyone knows what impossible means — the count won't reach it from the load, so it'll reach it from the caste. The booth is silent. People keep their eyes off the names beside them."
    }
  ],
  npcs: ["winnow_nils"],
  events: [],
  exits: [
    %Exit{id: "tally_to_galley", to: "winnow_galley"},
    %Exit{id: "tally_to_gantry", to: "winnow_gantry"}
  ]
}
