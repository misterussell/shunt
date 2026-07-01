alias Shunt.World.Exit

%{
  id: "bloom_standings",
  name: "The Standings",
  short_description:
    "A public gallery of who's up and who's down — the Bloom keeps score in the open.",
  description:
    "A lit gallery where the district's rankings hang for everyone to read: who rose this season, who fell, who's rumored next for the throat. People come to find their own name and leave having memorized everyone else's.",
  tags: [:midgrid, :gambling, :social],
  graph_position: {3560, -1880},

  # TODO: flavor-only social leaderboard — no core wiring required. Atmosphere shifts with :season
  # (the board is polite at :gilded, a bloodbath at :cascade). Optional NPC obsessing over their
  # rank. Sells the reputation-as-currency theme in one glance.
  npcs: [],
  events: [],
  exits: [
    %Exit{id: "standings_to_floor", to: "bloom_floor"}
  ]
}
