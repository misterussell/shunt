alias Shunt.World.Exit

%{
  id: "crossgate_service_spine",
  name: "Service Spine",

  short_description:
    "The maintenance corridor that runs the length of the interchange.",

  description:
    "A long service corridor running beneath the platforms, connecting infrastructure points the official operators needed to access quickly. Pipes, conduit, junction boxes. It sees more traffic now than it ever did when the interchange ran legally — mostly people who don't want their movements logged at the Tollgate.",

  tags: [
    :infrastructure,
    :underbelly
  ],

  graph_position: {750, 530},

  events: [
    "crossgate_service_spine_bypass_marking"
  ],

  exits: [
    %Exit{
      id: "service_spine_to_lower_concourse",
      to: "crossgate_lower_concourse"
    },
    %Exit{
      id: "service_spine_to_cold_storage",
      to: "crossgate_cold_storage"
    },
    %Exit{
      id: "service_spine_to_transit_tunnel",
      to: "crossgate_transit_tunnel",
      requirements: [
        {:knows, "crossgate_service_spine_bypass"}
      ]
    }
  ]
}
