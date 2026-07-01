alias Shunt.World.Exit

%{
  id: "bloom_ashfall",
  name: "The Ashfall",
  short_description: "Where the night comes down — the comedown squalor under the neon.",
  description:
    "The bottom of the party petal, where the burn leaves its ash: people come down here, or don't come back up. The neon still runs, but you can see the soot on the vent walls behind it now, and the gilt stops pretending.",
  tags: [:midgrid, :nightlife],
  graph_position: {2440, -2120},
  atmosphere: [
    %{
      requirements: [],
      text:
        "The comedown squalor under the neon, quiet and gilded over, the soot on the vent walls just visible behind the light."
    },
    %{
      requirements: [{:district, "bloom", :season, :>=, :churning}],
      text:
        "The Ashfall fills as the season turns — the fallen washing down here faster than the light can hide them, the gilt peeling off the walls in plain sight."
    },
    %{
      requirements: [{:district, "bloom", :season, :>=, :cascade}],
      text:
        "The Ashfall is full of the season's dead — names that blazed last week, down here in the ash now, and nobody left up top with the standing to pretend it isn't happening."
    }
  ],

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
