alias Shunt.World.Exit

%{
  id: "shunt9_cold_store",
  name: "Cold Store",

  # Territory premises — the class-2 safehouse you relocate into once a corner isn't enough.
  # A disused refrigerated stockroom back behind the food-stall row: thick insulated walls,
  # one bolted way in, dead quiet. The :relocation block is what relocate/2 reads (cost + gates).
  # See priv/docs/SHUNT_territory_ladder_v1.md §6. (Name provisional — pending Constitution pass.)
  premises_class: 2,
  relocation: %{
    cost: %{scrip: 400, cred: 30},
    requirements: []
  },

  # Only walkable on the map once it's yours: gated until you've relocated here (premises class 2).
  # relocate/2 and the Hideout relocation catalog read the :relocation block directly, so you still
  # see and choose it before then — you just can't stroll in until you hold it.
  requirements: [{:premises_at_least, 2}],

  short_description:
    "A sealed cold store behind the food stalls.",

  description:
    "A refrigeration plant that quit decades ago, back behind the stall row where the vendors " <>
      "once kept their stock. Insulated walls a hand thick and a single bolted hatch. Cold, dark, " <>
      "and defensible — room enough for a real operation, if you can hold it.",

  tags: [
    :home,
    :safe
  ],

  graph_position: {100, 570},

  exits: [
    %Exit{
      id: "cold_store_to_food_stalls",
      to: "shunt9_food_stalls"
    }
  ]
}
