alias Shunt.World.Exit

%{
  id: "crossgate_concourse",
  name: "The Concourse",

  short_description:
    "The Crossgate's beating heart. Loud, crowded, always open.",

  description:
    "A vaulted transit concourse, its original ceiling still intact — cracked but standing, looming over a floor packed with permanent storefronts built into the old ticket booths and service alcoves. Generator-powered lighting runs twenty-four hours. The smell of food, machine oil, and too many people in a sealed space.",

  tags: [
    :market,
    :social,
    :underbelly
  ],

  graph_position: {900, 230},

  events: [
    "crossgate_concourse_departures_board"
  ],

  exits: [
    %Exit{
      id: "concourse_to_tollgate",
      to: "crossgate_tollgate"
    },
    %Exit{
      id: "concourse_to_commissary",
      to: "crossgate_commissary"
    },
    %Exit{
      id: "concourse_to_west_platform",
      to: "crossgate_west_platform"
    },
    %Exit{
      id: "concourse_to_graft_den",
      to: "crossgate_graft_den"
    },
    %Exit{
      id: "concourse_to_the_pit",
      to: "crossgate_the_pit"
    },
    %Exit{
      id: "concourse_to_relay_block",
      to: "crossgate_relay_block"
    },
    %Exit{
      id: "concourse_to_house_of_closed_hands",
      to: "crossgate_house_of_closed_hands",
      requirements: [
        {:knows, "crossgate_house_entry_granted"}
      ]
    },
    %Exit{
      id: "concourse_to_liftworks_intake",
      to: "liftworks_intake_hall",
      requirements: [
        {:knows, "liftworks_route"}
      ]
    }
  ]
}
