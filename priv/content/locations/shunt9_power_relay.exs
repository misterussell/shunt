%{
  key: "shunt9_power_relay",
  name: "Power Relay",

  short_description:
    "A humming substation feeding what's left of Shunt 9.",

  description:
    "Cables thick as a man's arm snake between rusted transformers, throwing off heat and a low electrical hum that never quite stops.",

  tags: [
    :infrastructure,
    :restricted
  ],

  graph_position: {500, 100},

  # TODO: alias Shunt.World.Exit and convert the map below to %Exit{to: ...},
  # dropping requirements: [] (matches the struct default).
  exits: [
    %{to: "shunt9_bazaar", requirements: []}
  ]
}
