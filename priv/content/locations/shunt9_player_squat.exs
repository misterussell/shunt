alias Shunt.World.Exit

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

  graph_position: {700, 400},

  # TODO: add an `events:` key once priv/content/events/shunt9/player_squat_*.exs are
  # authored and :events is loaded by Content.Store:
  #   events: [
  #     "shunt9_player_squat_deck",
  #     "shunt9_player_squat_neural_port",
  #     "shunt9_player_squat_knowledge_chits"
  #   ],

  exits: [
    %Exit{to: "shunt9_maintenance_tunnel"}
  ]
}
