alias Shunt.World.Exit

%{
  id: "bloom_overlook",
  name: "The Overlook",
  short_description: "A VIP lounge cantilevered over the throat; you come here to be seen.",
  description:
    "A glass shelf hung out over the throat, where the light is best and the drop is longest. Nobody comes to the Overlook to drink — they come to be watched drinking, close enough to the ascent gate to pretend they're next.",
  tags: [:midgrid, :nightlife, :social],
  graph_position: {2760, -2320},

  # TODO: flavor-only — no engine wiring required. Optional status-obsessed NPC for colour;
  # atmosphere on :draw (the view of the throat blazes/dims with the Spire's pull). Exists to make
  # the party petal feel deep and to sell the "performing you've already made it" theme.
  npcs: [],
  events: [],
  exits: [
    %Exit{id: "overlook_to_burnoff", to: "bloom_burnoff"}
  ]
}
