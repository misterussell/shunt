alias Shunt.World.Exit

%{
  id: "crossgate_the_register",
  name: "The Register",

  short_description:
    "An information broker's office, tucked behind the Commissary.",

  description:
    "A back office with a clean front — filing cabinets, a desk, a lamp that actually works. Nothing on the walls says what this place does. The person behind the desk does not volunteer information unless you've been pointed here by someone they trust.",

  tags: [
    :information,
    :underbelly
  ],

  graph_position: {1050, 80},

  npcs: [
    "crossgate_register_cipher"
  ],

  events: [
    "crossgate_register_liftworks_word"
  ],

  exits: [
    %Exit{
      id: "the_register_to_commissary",
      to: "crossgate_commissary"
    }
  ]
}
