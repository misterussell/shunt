alias Shunt.World.Exit

%{
  id: "liftworks_the_risers",
  name: "The Risers",

  short_description:
    "The freight lifts. The only honest way out of the Underbelly — if they'll take you.",

  description:
    "A cathedral of machinery: counterweights the size of trucks, cable drums worn smooth, three freight lifts that still run between the strata. One stands open and waiting. A reader beside it blinks for clearance the floor doesn't hand out twice. Up is up — the Midgrid is the next stop on the line — but the lift doesn't move for anyone the checkpoint hasn't cleared.",

  tags: [
    :transit,
    :authority,
    :underbelly
  ],

  graph_position: {1350, -120},

  events: [
    "liftworks_risers_the_lift"
  ],

  exits: [
    %Exit{
      id: "the_risers_to_intake_hall",
      to: "liftworks_intake_hall"
    },
    %Exit{
      id: "the_risers_ascent_permit",
      to: "liftworks_upper_landing",
      requirements: [
        {:has_item, "transit_permit"}
      ]
    },
    %Exit{
      id: "the_risers_ascent_spoof",
      to: "liftworks_upper_landing",
      requirements: [
        {:knows, "scan_arch_spoofed"}
      ]
    },
    %Exit{
      id: "the_risers_ascent_back_route",
      to: "liftworks_upper_landing",
      requirements: [
        {:knows, "liftworks_back_route"}
      ]
    },
    %Exit{
      id: "the_risers_ascent_ghost_clearance",
      to: "liftworks_upper_landing",
      requirements: [
        {:knows, "ghost_clearance"}
      ]
    }
  ]
}
