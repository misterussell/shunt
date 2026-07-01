alias Shunt.World.Exit

%{
  id: "windlass_the_skim",
  name: "The Skim",

  short_description:
    "A service void behind the market where the unread go to ground.",

  description:
    "A gap between the market's back wall and the coil itself, wide enough to live in if you don't mind the noise and the damp. It's where the market's hollows end up — the porters and sweepers and stall-hands the district needs but won't read, the people who'll be first onto the Authority's purge list when the count comes. They hear everything the floor says and they say very little back, which makes The Skim the best place in the Windlass to learn what the market is really carrying.",

  tags: [
    :midgrid,
    :social
  ],

  graph_position: {2860, -1280},

  npcs: [
    "windlass_marrow",
    # Wick surfaces once word of your digging (the purge-list rumor) reaches the Skim.
    %{id: "windlass_wick", requirements: [{:has_rumor, "windlass_permit_purge"}]}
  ],

  events: [
    "windlass_marrow_intro"
  ],

  exits: [
    %Exit{
      id: "the_skim_to_coil_market",
      to: "windlass_coil_market"
    }
  ]
}
