alias Shunt.World.Exit

%{
  id: "crossgate_the_pit",
  name: "The Pit",

  short_description:
    "Where two lines crossed and collapsed. Now people live here.",

  description:
    "The deepest point of the interchange, where two track lines once crossed underground and the roof eventually followed them down. The rubble was never cleared — it was built on instead. Four floors of improvised residential structure cling to the original walls, connected by ladders, rope lines, and nerve. The lowest level still floods when it rains above.",

  tags: [
    :residential,
    :underbelly
  ],

  graph_position: {900, 380},

  events: [
    "crossgate_the_pit_tethered_lines"
  ],

  exits: [
    %Exit{
      id: "the_pit_to_concourse",
      to: "crossgate_concourse"
    },
    %Exit{
      id: "the_pit_to_graft_den",
      to: "crossgate_graft_den"
    },
    %Exit{
      id: "the_pit_to_lower_concourse",
      to: "crossgate_lower_concourse"
    }
  ]
}
