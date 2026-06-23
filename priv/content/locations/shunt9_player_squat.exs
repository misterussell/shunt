%{
  key: "shunt9_player_squat",
  name: "Player Squat",

  short_description:
    "Your squat, such as it is.",

  description:
    "A reinforced storage unit converted into a place to sleep, with just enough room for a cot, a workbench, and whatever you haven't sold yet.",

  tags: [
    :home,
    :safe
  ],

  graph_position: {500, 900},

  # TODO: alias Shunt.World.Exit and convert the map below to %Exit{to: ...},
  # dropping requirements: [] (matches the struct default).
  exits: [
    %{to: "shunt9_maintenance_tunnel", requirements: []}
  ]
}
