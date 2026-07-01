alias Shunt.World.Exit

%{
  id: "bloom_reserve",
  name: "The Reserve",
  short_description: "The private booths, where the vouches and the knives come out.",
  description:
    "Curtained booths off the Spread, reserved for people with something to trade in private: a vouch, a secret, a name to sink. The waiters here are paid to forget faces. This is where the Web does its quiet work.",
  tags: [:midgrid, :dining, :social],
  graph_position: {2560, -1970},

  # TODO: gated Web deal-space (via bloom_reserve_invited). A Whisper Syndicate contact who
  # brokers reputation here; a required investigation rumor sourced in the booths; the
  # RumorConnection's partial resolution may surface here. Cred/favor changes hands.
  npcs: ["bloom_yara"],
  events: [],
  exits: [
    %Exit{id: "reserve_to_spread", to: "bloom_spread"}
  ]
}
