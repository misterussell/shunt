alias Shunt.World.Exit

%{
  id: "shunt9_player_squat",
  name: "Player Squat",

  # Territory premises (the player's starting home base). Class 1 — the Squatter shell.
  # See priv/docs/SHUNT_territory_ladder_v1.md.
  premises_class: 1,

  short_description:
    "Your squat, such as it is.",

  description:
    "A reinforced storage unit converted into a place to sleep, with just enough room for a cot, a workbench, and whatever you haven't sold yet.",

  tags: [
    :home,
    :safe
  ],

  graph_position: {700, 400},

  events: [
    "shunt9_player_squat_deck",
    "shunt9_player_squat_neural_port",
    "shunt9_player_squat_knowledge_chits"
  ],

  exits: [
    %Exit{
      id: "player_squat_to_maintenance_tunnel",
      to: "shunt9_maintenance_tunnel"
    }
  ]
}
