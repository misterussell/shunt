alias Shunt.World.Exit

%{
  id: "shunt9_burned_platform",
  name: "Burned Platform",

  short_description:
    "A scorched transit platform, long since abandoned.",

  description:
    "Soot-blackened girders mark where a fire gutted this stretch of the line years ago. Nobody talks about how it started.",

  tags: [
    :ruins,
    :underbelly
  ],

  graph_position: {400, 400},

  events: [
    "shunt9_burned_platform_melted_door"
  ],

  exits: [
    %Exit{
      id: "burned_platform_to_bazaar",
      to: "shunt9_bazaar"
    },
    %Exit{
      id: "burned_platform_to_maintenance_tunnel",
      to: "shunt9_maintenance_tunnel"
    }
  ]
}
