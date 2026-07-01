alias Shunt.World.Exit

%{
  id: "bloom_burnoff",
  name: "The Burnoff",
  short_description: "The flagship bar, in a duct where the Spire once flared off its excess.",
  description:
    "A vent-stack the Spire used to flare its waste gas through, now the loudest bar in the Bloom — the excess still burns here, just a different kind. Everyone who matters passes through the Burnoff, and everyone who wants to matter is trying to.",
  tags: [:midgrid, :nightlife, :social],
  graph_position: {2790, -2170},

  # TODO: bartender NPC who trades in what people say when they drink; Web rumor-source events
  # (this is a primary place to pick up leads); atmosphere on :draw (the burn roars brighter as
  # the Spire pulls); seed at least one rumor here; the "bloom_den_vouched" flag that opens the
  # Afterburn is earned somewhere in the party petal (here or via the bartender).
  npcs: [],
  events: [],
  exits: [
    %Exit{id: "burnoff_to_throat", to: "bloom_throat"},
    %Exit{id: "burnoff_to_overlook", to: "bloom_overlook"},
    # The den doesn't open to strangers.
    %Exit{
      id: "burnoff_to_afterburn",
      to: "bloom_afterburn",
      requirements: [{:knows, "bloom_den_vouched"}]
    }
  ]
}
