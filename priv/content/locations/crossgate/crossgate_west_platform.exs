alias Shunt.World.Exit

%{
  id: "crossgate_west_platform",
  name: "West Platform",

  short_description:
    "The old platform, wired up for something louder than transit.",

  description:
    "A former train platform converted into an entertainment strip. The original conductor's booth is now a bar. The track bed is a fighting pit three nights a week. Betting slips and spilled drinks cover most of the floor. It's the closest thing The Crossgate has to a social venue, which says something about The Crossgate.",

  tags: [
    :social,
    :underbelly
  ],

  graph_position: {1050, 230},

  events: [
    "crossgate_west_platform_fight_board"
  ],

  exits: [
    %Exit{
      id: "west_platform_to_concourse",
      to: "crossgate_concourse"
    },
    %Exit{
      id: "west_platform_to_the_drop",
      to: "crossgate_the_drop",
      requirements: [
        {:knows, "crossgate_the_drop_location"}
      ]
    }
  ]
}
