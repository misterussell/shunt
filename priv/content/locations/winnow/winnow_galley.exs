alias Shunt.World.Exit

%{
  id: "winnow_galley",
  name: "The Galley",
  short_description:
    "The caste's warren — bunks, a black market, and the closest thing to a foothold up here.",
  description:
    "Behind the Sorting Floor, in the dead space the wardens don't bother to light, the caste keeps a warren: stacked bunks, a boiled-tea galley, and a quiet market running off whatever the reclaim benches skim. It's the one room in the Winnow that belongs to the people in it, which up here counts as luxury. Take a bunk and work the line and you can hold a corner of the Spire — the best address a spoiled thing like you was ever going to get, and a good deal warmer than the belt.",
  tags: [:spire, :hideout, :latticework],
  graph_position: {3000, -2760},

  # Tier-7 "Relay" premises (class 3) — home for the Line Tap income module (splices the reclaim
  # conveyor). Reachable off the Sorting Floor; moving in is cred-heavy (the Spire tier) with no
  # extra gate flag beyond having arrived.
  premises_class: 3,
  relocation: %{
    cost: %{scrip: 900, cred: 140},
    requirements: [{:knows, "winnow_arrived"}]
  },
  atmosphere: [
    %{
      requirements: [],
      text:
        "The warren keeps its head down — low talk, quick trade, everyone careful not to say the thing everyone's thinking, which is that any of them could be on the belt by next quota."
    },
    %{
      requirements: [{:district, "winnow", :waking, :>=, :lucid}],
      text:
        "The warren doesn't whisper anymore. The caste has come all the way awake to what they are and what they've been made to do, and the galley has stopped being a place to hide and started being a place to plan."
    }
  ],
  npcs: ["winnow_roan"],
  events: [],
  exits: [
    %Exit{id: "galley_to_sorting", to: "winnow_sorting_floor"},
    %Exit{id: "galley_to_tally", to: "winnow_tally"}
  ]
}
