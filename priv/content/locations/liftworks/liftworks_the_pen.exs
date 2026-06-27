alias Shunt.World.Exit

%{
  id: "liftworks_the_pen",
  name: "The Pen",

  short_description:
    "Holding, for the ones who didn't clear. They wait. Some deal.",

  description:
    "A railed-off side hall where the turned-back sit on bolted benches, papers wrong or papers short. A bored guard reads a screen by the gate. The air is patient and a little sour. People here have time, and time in a place like this turns into the kind of arrangements that don't get written down.",

  tags: [
    :authority,
    :social,
    :underbelly
  ],

  graph_position: {1500, 70},

  npcs: [
    "liftworks_proxy"
  ],

  events: [
    "liftworks_pen_turned_back"
  ],

  exits: [
    %Exit{
      id: "the_pen_to_intake_hall",
      to: "liftworks_intake_hall"
    }
  ]
}
