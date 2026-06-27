alias Shunt.World.Exit

%{
  id: "crossgate_cold_storage",
  name: "Cold Storage",

  short_description:
    "Old refrigeration infrastructure, now a grey-market warehouse.",

  description:
    "The interchange's original cold storage units — six heavy insulated rooms once used for perishable cargo. Two still hold temperature. The others run as a grey-market auction point: unclaimed crates, consignment goods, items whose origin paperwork has been lost intentionally. A percentage of everything sold here goes to the Syndicate.",

  tags: [
    :market,
    :underbelly
  ],

  graph_position: {1050, 380},

  events: [
    "crossgate_cold_storage_unclaimed_crate"
  ],

  exits: [
    %Exit{
      id: "cold_storage_to_service_spine",
      to: "crossgate_service_spine"
    },
    %Exit{
      id: "cold_storage_to_relay_block",
      to: "crossgate_relay_block"
    },
    %Exit{
      id: "cold_storage_to_concourse",
      to: "crossgate_concourse"
    }
  ]
}
