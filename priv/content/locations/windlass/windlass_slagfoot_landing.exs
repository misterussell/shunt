alias Shunt.World.Exit

%{
  id: "windlass_slagfoot_landing",
  name: "Slagfoot Landing",

  short_description:
    "Where the freight from the Grayline lands, at the foot of the coil.",

  description:
    "The transit line ends here, at the bottom of the great coil — a freight platform of scarred plate and cold cranes, where cargo up from the Grayline is supposed to be broken down and sent climbing. The Windlass rises overhead, turn on turn, a whole city wound up an engine the size of a district. Most of the cranes hang still. Whatever moves through the Landing now moves by hand.",

  tags: [
    :midgrid,
    :transit,
    :industrial
  ],

  graph_position: {2600, -640},

  # Ambient shifts with the Haul: dead yard while the engine is stalled, working yard once freight climbs.
  atmosphere: [
    %{requirements: [], text: "The cranes are cold and the coil above them is silent. Dockhands sit on crates they can't fill, waiting on a haul that hasn't run in weeks."},
    %{requirements: [{:district, "windlass", :haul, :>=, :running}], text: "The coil is turning again. Freight rides the great screw up into the city and the Landing works the way it was built to — loud, filthy, and busy enough that nobody watches the door."}
  ],

  npcs: [
    "windlass_hopper"
  ],

  events: [
    "windlass_slagfoot_arrival"
  ],

  exits: [
    %Exit{
      id: "landing_to_slagworks",
      to: "windlass_slagworks"
    },
    %Exit{
      id: "landing_to_coil_stair",
      to: "windlass_coil_stair"
    },
    # Back down the freight line to the Grayline — the way in is also the way out.
    %Exit{
      id: "landing_to_grayline_glassline",
      to: "grayline_glassline",
      travel_text:
        "You ride the freight line back down out of the Windlass, work-lamps thinning into the clean concourse until the Glassline's turnstiles come up ahead — the Grayline again, and past it the way down you came."
    }
  ]
}
