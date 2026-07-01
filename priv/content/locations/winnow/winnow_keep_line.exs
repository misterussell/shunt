alias Shunt.World.Exit

%{
  id: "winnow_keep_line",
  name: "The Keep Line",
  short_description:
    "The right belt — where the winnow's chosen go up to be inducted and stored.",
  description:
    "The belt everyone on the Maw prays they land on. Kept arrivals ride it up out of the Sorting Floor toward induction, where a clean shunt gets seated the rest of the way and a mind gets filed into the Latticework whole enough to keep working. Up top they call this ascension. Down on the belt it looks like inventory being shelved. The kept don't struggle. Most of them are still smiling from the throat, believing the last thing the Bloom told them.",
  tags: [:spire, :infrastructure, :latticework],
  graph_position: {3140, -2600},
  atmosphere: [
    %{
      requirements: [],
      text:
        "The belt hums bright and orderly, arrivals riding up in their good clothes, the induction gate above swallowing them one after another without a hitch."
    },
    %{
      requirements: [{:district, "winnow", :quota, :>=, :easing}],
      text:
        "The Keep runs full and unhurried — enough good load coming up the throat that the winnow can afford to be honest, and the belt carries the kept up gently, the way the story always promised it would."
    }
  ],
  npcs: [],
  events: [],
  exits: [
    %Exit{id: "keep_to_maw", to: "winnow_maw"},
    %Exit{id: "keep_to_sorting", to: "winnow_sorting_floor"}
  ]
}
