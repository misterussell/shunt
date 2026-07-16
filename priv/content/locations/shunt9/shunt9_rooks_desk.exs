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
    {:knows, "rook"}
  ],

  # TODO (Rook fold-in): surface the Rook world NPC here so the player can talk to him in person.
  # Add: npcs: ["shunt9_rook"]  (see priv/content/world_npcs/shunt9/shunt9_rook.exs).

  exits: [
    %Exit{
      id: "rooks_desk_to_bazaar",
      to: "shunt9_bazaar"
    }
  ]
}
