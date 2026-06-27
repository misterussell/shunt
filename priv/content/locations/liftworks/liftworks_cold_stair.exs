alias Shunt.World.Exit

%{
  id: "liftworks_cold_stair",
  name: "The Cold Stair",

  short_description:
    "A dead service stair the Authority stopped watching. The unofficial way up.",

  description:
    "A concrete stairwell the checkpoint forgot — lights long dead, the scan arch's reach ending two flights below. Cabling runs bare up the wall where someone has been tapping the line. It climbs past the intake floor and comes out near the lift machinery, no desks, no notices, no one asking for papers. You only find it if someone tells you it's here.",

  tags: [
    :latticework,
    :restricted,
    :underbelly
  ],

  graph_position: {1200, 0},

  events: [
    "liftworks_cold_stair_back_route",
    "liftworks_cold_stair_off_hours"
  ],

  exits: [
    %Exit{
      id: "cold_stair_to_intake_hall",
      to: "liftworks_intake_hall"
    }
  ]
}
