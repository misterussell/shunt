alias Shunt.World.Exit

%{
  id: "windlass_ascent_office",
  name: "The Ascent Office",

  short_description:
    "The Kaspav Authority's checkpoint at the top of the coil.",

  description:
    "The office that decides who leaves the Windlass going up. A scan arch, a permit desk, and the patient machinery of the Kaspav Authority, all of it built to make ascent feel like a privilege rather than a wall. This is where the district's permits are issued and the district's records are kept — including, somewhere in the registry behind the desk, whatever the Authority is telling itself about why the freight stopped. The clerks are polite. The readers are not.",

  tags: [
    :midgrid,
    :transit,
    :latticework
  ],

  graph_position: {2500, -1460},

  # The permit registry — the scan arch's brain — runs the hardest node in the district.
  lattice: %{
    leads: [
      %{
        id: "scan_arch_signal",
        requirements: [],
        text: "The scan arch talks to a registry deep behind the desk — permits, purge lists, and the paperwork behind both. It's current-spec and it bites. But it's all in there.",
        on_intercept: [{:knowledge, "windlass_scan_arch_found"}]
      }
    ],
    filler: [
      %{weight: 3, text: "Permit validations, one after another, each one a person being let up or turned back.", on_intercept: []},
      %{weight: 2, text: "An Authority advisory, encrypted past casual reading. You note the shape of it.", on_intercept: []}
    ]
  },

  npcs: [
    "windlass_vane"
  ],

  events: [
    "windlass_vane_intro"
  ],

  exits: [
    %Exit{
      id: "ascent_office_to_high_anchor",
      to: "windlass_high_anchor"
    }
  ]
}
