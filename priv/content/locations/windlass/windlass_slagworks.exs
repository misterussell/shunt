alias Shunt.World.Exit

%{
  id: "windlass_slagworks",
  name: "The Slagworks",

  short_description:
    "The foundry floor at the base of the coil. Heat, noise, and old iron.",

  description:
    "The first full turn of the Windlass is a foundry that never fully cooled. Furnaces line the outer wall, most banked low, and the floor is a maze of casting pits, cranes, and men who've given the place their hearing. The work here feeds the engine room deeper in — when the engine runs. It hasn't, and the Slagworks has the sour, idle feel of a crew paid to wait.",

  tags: [
    :midgrid,
    :industrial,
    :social
  ],

  graph_position: {2860, -760},

  atmosphere: [
    %{requirements: [], text: "Half the furnaces are cold. The crews stand around them anyway, out of habit, because standing near a cold furnace still beats going home."},
    %{requirements: [{:district, "windlass", :haul, :>=, :running}], text: "The furnaces are up and the floor is moving, casting parts the engine needs faster than it can eat them. It's brutal work, and the crews would rather have it than not."}
  ],

  npcs: [
    "windlass_ratchet",
    "windlass_tallow"
  ],

  events: [
    "windlass_ratchet_intro",
    "windlass_ratchet_engine_job",
    "windlass_tallow_chrome"
  ],

  exits: [
    %Exit{
      id: "slagworks_to_landing",
      to: "windlass_slagfoot_landing"
    },
    # The engine room runs superheated; you don't get through this door without the chrome to survive it.
    %Exit{
      id: "slagworks_to_winding_deck",
      to: "windlass_winding_deck",
      requirements: [{:knows, "windlass_chrome_installed"}],
      travel_text: "The heat past the blast door hits like a wall, but the chrome under your skin holds the line. You go in."
    }
  ]
}
