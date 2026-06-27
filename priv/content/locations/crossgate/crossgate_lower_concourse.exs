alias Shunt.World.Exit

%{
  id: "crossgate_lower_concourse",
  name: "Lower Concourse",

  short_description:
    "The level below the main floor. Darker, wetter, quieter.",

  description:
    "The original lower level of the interchange — a wide corridor that once connected platforms and serviced arriving passengers. Now partially flooded at the far end, lit only by strip lights someone ran through the ceiling from above. People come here when they don't want to be seen doing whatever they're doing.",

  tags: [
    :infrastructure,
    :underbelly
  ],

  graph_position: {900, 530},

  events: [
    "crossgate_lower_concourse_flooded_track"
  ],

  exits: [
    %Exit{
      id: "lower_concourse_to_the_pit",
      to: "crossgate_the_pit"
    },
    %Exit{
      id: "lower_concourse_to_service_spine",
      to: "crossgate_service_spine"
    },
    %Exit{
      id: "lower_concourse_to_relay_block",
      to: "crossgate_relay_block"
    }
  ]
}
