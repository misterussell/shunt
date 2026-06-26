alias Shunt.World.Exit

%{
  id: "shunt9_supplier_drop",
  name: "Supplier Drop",

  short_description:
    "A blind alcove behind the bazaar where Juno's stock changes hands.",

  description:
    "A maintenance alcove sealed off behind a false stall wall. Crates wait in the dark, tagged in a shorthand only a few people can read. This is where Juno's goods enter Shunt 9 before anyone official knows they exist.",

  tags: [
    :underbelly,
    :restricted
  ],

  graph_position: {150, 250},

  requirements: [
    {:knows, "juno_secret_supplier"}
  ],

  events: [
    "shunt9_bazaar_juno_supplier_investigation"
  ],

  exits: [
    %Exit{
      id: "supplier_drop_to_bazaar",
      to: "shunt9_bazaar"
    }
  ]
}
