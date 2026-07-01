alias Shunt.World.Exit

%{
  id: "bloom_ashfall",
  name: "The Ashfall",
  short_description: "Where the night comes down — the comedown squalor under the neon.",
  description:
    "The bottom of the party petal, where the burn leaves its ash: people come down here, or don't come back up. The neon still runs, but you can see the soot on the vent walls behind it now, and the gilt stops pretending.",
  tags: [:midgrid, :nightlife],
  graph_position: {2440, -2120},

  # TODO: flavor-only pocket-of-C — no core wiring required. Atmosphere that curdles as :season
  # rises (the higher the scandal-heat, the uglier this room reads). Optional NPC (someone the
  # Bloom used up). Sells the "A with pockets of C" tone at its bleakest.
  npcs: [
    # Renata only surfaces once the scene's gone loud enough for the used-up to talk.
    %{id: "bloom_renata", requirements: [{:district, "bloom", :season, :>=, :churning}]}
  ],
  events: [],
  exits: [
    %Exit{id: "ashfall_to_afterburn", to: "bloom_afterburn"}
  ]
}
