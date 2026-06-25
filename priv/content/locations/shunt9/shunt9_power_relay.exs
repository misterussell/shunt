alias Shunt.World.Exit

%{
  id: "shunt9_power_relay",
  name: "Power Relay",

  short_description:
    "A humming substation feeding what's left of Shunt 9.",

  description:
    "Cables thick as a man's arm snake between rusted transformers, throwing off heat and a low electrical hum that never quite stops.",

  tags: [
    :infrastructure,
    :restricted
  ],

  graph_position: {100, 400},

  exits: [
    %Exit{
      id: "power_relay_to_bazaar",
      to: "shunt9_bazaar"
    }
  ]
}
