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

  # TODO: alias Shunt.World.Exit and convert each map below to %Exit{to: ...},
  # dropping requirements: [] (matches the struct default).
  exits: [
    %{to: "shunt9_bazaar", requirements: []},
    %{to: "shunt9_maintenance_tunnel", requirements: []}
  ]
}
