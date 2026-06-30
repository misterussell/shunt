alias Shunt.World.Exit

%{
  id: "shunt9_cold_store",
  name: "Cold Store",

  # Territory premises — the class-2 safehouse you relocate into once a corner isn't enough.
  # A disused refrigerated stockroom off the service runs: thick insulated walls, one bolted
  # way in, dead quiet. The :relocation block is what relocate/2 reads (cost + gates).
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
    "A sealed cold store off the service runs.",

  description:
    "A refrigeration plant that quit decades ago, insulated walls a hand thick and a single " <>
      "bolted hatch. Cold, dark, and defensible — room enough for a real operation, if you can " <>
      "hold it.",

  tags: [
    :home,
    :safe
  ],

  graph_position: {550, 520},

  exits: [
    %Exit{
      id: "cold_store_to_maintenance_tunnel",
      to: "shunt9_maintenance_tunnel"
    }
  ]
}
