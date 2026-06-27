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
      travel_text:
        "You feed the permit to the reader. It chirps, the gate releases, and the lift takes your weight and begins to climb.",
      requirements: [
        {:has_item, "transit_permit"}
      ]
    },
    %Exit{
      id: "the_risers_ascent_spoof",
      to: "liftworks_upper_landing",
      travel_text:
        "Your deck answers the reader before it can ask — a clean tag the scan arch already swallowed. The gate believes you. The lift climbs.",
      requirements: [
        {:knows, "scan_arch_spoofed"}
      ]
    },
    %Exit{
      id: "the_risers_ascent_back_route",
      to: "liftworks_upper_landing",
      travel_text:
        "You skip the reader entirely. The Cold Stair lets out beside the open car, and you step on before anyone thinks to ask. The lift climbs.",
      requirements: [
        {:knows, "liftworks_back_route"}
      ]
    }
  ]
}
