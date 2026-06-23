%{
  key: "shunt9_burned_platform",
  name: "Burned Platform",

  short_description:
    "A scorched transit platform, long since abandoned.",

  description:
    "Soot-blackened girders mark where a fire gutted this stretch of the line years ago. Nobody talks about how it started.",

  tags: [
    :ruins,
    :underbelly
  ],

  graph_position: {500, 500},

  exits: [
    %{to: "shunt9_bazaar", requirements: []},
    %{to: "shunt9_maintenance_tunnel", requirements: []}
  ]
}
