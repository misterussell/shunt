alias Shunt.World.Exit

%{
  id: "shunt9_freight_tunnel",
  name: "Freight Tunnel",

  short_description:
    "An old freight tunnel listed as decommissioned. The lights still work.",

  description:
    "Long enough that both ends disappear into the dark. The ceiling is low and riveted, original transit infrastructure from before the platform above it was built over. Coolant lines still hum along one wall. Crates sit in a staging alcove near the far end, tagged in a shorthand that doesn't match any public manifest.",

  tags: [
    :infrastructure,
    :underbelly,
    :restricted
  ],

  graph_position: {550, 570},

  requirements: [
    {:contact_known, "dex_broker"}
  ],

  exits: [
    %Exit{
      id: "freight_tunnel_to_maintenance_tunnel",
      to: "shunt9_maintenance_tunnel"
    }
  ]
}
