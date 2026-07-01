alias Shunt.World.Exit

%{
  id: "windlass_winding_deck",
  name: "The Winding Deck",

  short_description:
    "The engine room at the heart of the coil, where the great screw is driven.",

  description:
    "The engine that is the Windlass — a screw-drive the height of three floors, geared to the coil that carries the whole city. The air is a furnace even with the drive stopped; running, it would cook an unshielded body in minutes. The great gearing sits seized, and up close you can read why in the metalwork: this didn't wear out. Something was done to it, carefully, by someone who knew exactly which tooth to break.",

  tags: [
    :midgrid,
    :industrial,
    :latticework
  ],

  graph_position: {2560, -840},

  atmosphere: [
    %{requirements: [], text: "The drive is dead and the heat is the leftover kind, radiating out of iron that hasn't turned in weeks. In the stillness the sabotage is obvious to anyone who bothers to look."},
    %{requirements: [{:district, "windlass", :haul, :>=, :running}], text: "The screw turns, slow and enormous, and the whole deck shudders with it. The heat is a living thing now. You don't stay longer than the work demands."}
  ],

  events: [],

  exits: [
    %Exit{
      id: "winding_deck_to_slagworks",
      to: "windlass_slagworks"
    }
  ]
}
