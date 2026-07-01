alias Shunt.World.Exit

%{
  id: "bloom_cage",
  name: "The Cage",
  short_description: "The cashier's cage — markers, debt, and the Closed Hands who own them.",
  description:
    "The barred window where the Floor turns into money and money turns into markers. The Closed Hands run the Cage, and everyone who's ever been staked here knows the ascent they're chasing is really just the biggest marker of all.",
  tags: [:midgrid, :gambling],
  graph_position: {3300, -1830},

  # TODO: Closed Hands debt NPC/event (staking markers, calling them in); :book tie-in (the Cage
  # is where the district's debt is most visible); back-route to the Vent Run (compete side).
  npcs: [],
  events: [],
  exits: [
    %Exit{id: "cage_to_slate", to: "bloom_slate"},
    %Exit{id: "cage_to_vent_run", to: "bloom_vent_run"}
  ]
}
