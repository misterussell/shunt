alias Shunt.World.Exit

%{
  id: "shunt9_rooks_desk",
  name: "Rook's Desk",

  short_description:
    "A hidden desk tucked into a corner of the bazaar, where Rook waits for eager customers.",

  description:
    "Rook's fencing operation - for hot goods, stolen data, and other illicit services - is tucked into a corner of the bazaar. The desk is cluttered with tools, papers, and a few personal touches that hint at the person behind the business.",

  tags: [
    :market,
    :underbelly
  ],

  graph_position: {300, 300},

  requirements: [
    {:flag, :knows_rook}
  ],

  exits: [
    %Exit{
      id: "rooks_desk_to_bazaar",
      to: "shunt9_bazaar"
    }
  ]
}
