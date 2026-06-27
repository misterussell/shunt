alias Shunt.World.Exit

%{
  id: "liftworks_transfer_row",
  name: "Transfer Row",

  short_description:
    "A licensed market. Everything here is paid up and accounted for.",

  description:
    "A row of stalls under working strip light, each with a stamped permit nailed to the frame. The goods are ordinary — filters, fuse packs, clean water — and priced with a tariff already folded in. No shouting, no haggling, no one watching the exits. Order, because order is cheaper than trouble this close to the lifts.",

  tags: [
    :market,
    :authority,
    :underbelly
  ],

  graph_position: {1500, 230},

  npcs: [
    "liftworks_splice"
  ],

  events: [
    "liftworks_transfer_row_licensed_goods",
    "liftworks_transfer_row_cargo_discrepancy"
  ],

  exits: [
    %Exit{
      id: "transfer_row_to_intake_hall",
      to: "liftworks_intake_hall"
    }
  ]
}
