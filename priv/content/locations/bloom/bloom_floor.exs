alias Shunt.World.Exit

%{
  id: "bloom_floor",
  name: "The Floor",
  short_description:
    "The gambling tables — where reading the social game is the only edge that pays.",
  description:
    "The open floor of the compete petal: card rooms and wager tables where the Bloom's winners prove it and its losers become someone's mark. The games are all really the same game — who knows what about whom, and who bets on it first.",
  tags: [:midgrid, :gambling, :social],
  graph_position: {3440, -1970},

  # TODO: gambling NPC (a dealer/house operator); a heat-event tie (big losers draw Syndicate/
  # Authority attention); seed a rumor; :season flavour in the atmosphere. A natural place for the
  # Skim Crew's marks to come from.
  npcs: [],
  events: [],
  exits: [
    %Exit{id: "floor_to_slate", to: "bloom_slate"},
    %Exit{id: "floor_to_standings", to: "bloom_standings"}
  ]
}
