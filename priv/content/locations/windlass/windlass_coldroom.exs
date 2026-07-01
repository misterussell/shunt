alias Shunt.World.Exit

%{
  id: "windlass_coldroom",
  name: "The Coldroom",

  short_description:
    "The Latticework Collective's den, off-grid behind the Fitworks.",

  description:
    "A dead space behind the fabrication floor — cold because it's been scrubbed off every reader and manifest in the district, a hollow the grid doesn't know is here. Decks line the walls, half of them cracked open to their guts, and the people around them talk in the flat, careful way of a crew that has decided the Authority is not a government but a weather system to be survived. This is where the Collective decides what the Windlass is allowed to know.",

  tags: [
    :midgrid,
    :latticework,
    :social
  ],

  graph_position: {2260, -1080},

  atmosphere: [
    %{requirements: [], text: "The Coldroom runs tight and quiet, a crew doing careful work against a grid that's beating them. There's a grudge in the room you could warm your hands on."},
    %{requirements: [{:district, "windlass", :grid, :>=, :open}], text: "The Coldroom is loud for once. The grid runs open above them and the crew here can barely believe they're the ones who did it."}
  ],

  # The deepest signal in the district — the backbone the whole Windlass grid rides on.
  lattice: %{
    leads: [
      %{
        id: "grid_core_signal",
        requirements: [{:knows, "windlass_collective_vouched"}],
        text: "From inside the Coldroom you can finally see it: the grid core, the trunk every Authority reader in the Windlass hangs off. Crack that and the whole district goes dark to them at once.",
        on_intercept: [{:knowledge, "windlass_grid_core_found"}]
      }
    ],
    filler: [
      %{weight: 3, text: "Collective traffic, rerouted six ways so no reader can follow it home.", on_intercept: []},
      %{weight: 2, text: "An old Collective cache, half-corrupted. You pull a few credits of clean signal.", on_intercept: [{:scrip, 4}]}
    ]
  },

  npcs: [
    "windlass_drift"
  ],

  events: [
    "windlass_drift_intro",
    "windlass_drift_loft"
  ],

  exits: [
    %Exit{
      id: "coldroom_to_fitters_floor",
      to: "windlass_fitters_floor"
    }
  ]
}
