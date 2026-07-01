alias Shunt.World.Exit

%{
  id: "winnow_sorting_floor",
  name: "The Sorting Floor",
  short_description:
    "The winnow itself — where the caste reads each arrival and sends it one of two ways.",
  description:
    "A long shed of a room straddling three conveyor lines, where the servant caste stands at the belt and sorts what the Maw brings up. Every arrival gets read — a jaw, a seam, a shunt that took clean or didn't — and shoved left to the Cull or right to the Keep. The people doing the sorting look exactly like the people on the belt. That's the part nobody says out loud: the winnowers came up the throat too, and the only difference between them and the load is that someone decided they were still useful.",
  tags: [:spire, :infrastructure, :latticework],
  graph_position: {3000, -2620},
  atmosphere: [
    %{
      requirements: [],
      text:
        "The belts crawl steady and the caste works the line with their heads down, sorting at the pace the number demands, saying nothing to the load and less to each other."
    },
    %{
      requirements: [{:district, "winnow", :quota, :>=, :culling}],
      text:
        "The belts run too fast to read anyone right, and it doesn't matter — when the number can't be made from the load, the wardens make it from the line, and the caste sorts double-time pretending they can't see who's missing from the belt beside them."
    },
    %{
      requirements: [{:district, "winnow", :waking, :>=, :stirring}],
      text:
        "Something's changed in how they work. Hands slow at the belt, eyes come up, a Keep gets waved through that a month ago would've gone Cull. The caste has started, very quietly, to cheat the winnow in favor of its own."
    }
  ],

  # Street Alchemy: the winnow_sorting_line repairable lives here (surfaced by location_id) and
  # drives the district :quota fact — clearing the backlogged line eases the pressure (nobody culled
  # for numbers), a rough patch takes some off, jamming it forces a reckoning.
  # Ghostwork: the lattice lead opens the line's controller (winnow_line_ice), whose crack drops the
  # ICE-locked investigation rumor winnow_directive (proof the quota comes from above the wardens).
  lattice: %{
    leads: [
      %{
        id: "line_controller",
        requirements: [],
        text:
          "The belts don't decide their own speed. There's a controller feeding the line its pace and its quota, and the pace-orders come in from somewhere off the Floor entirely — a channel you could get behind.",
        on_intercept: [{:knowledge, "winnow_line_ice_found"}]
      }
    ],
    filler: [
      %{
        weight: 3,
        text: "Sort-tags scrolling past, each arrival flagged Keep or Cull before it's off the Maw.",
        on_intercept: []
      },
      %{
        weight: 2,
        text: "A shunt-handshake off the belt — the interface in a fresh arrival's skull, pinging to be read.",
        on_intercept: []
      },
      %{
        weight: 1,
        text: "A miscounted lot manifest. You skim a little off the discrepancy.",
        on_intercept: [{:scrip, 5}]
      }
    ]
  },
  npcs: ["winnow_edda"],
  events: [],
  exits: [
    %Exit{id: "sorting_to_maw", to: "winnow_maw"},
    %Exit{id: "sorting_to_cull", to: "winnow_cull_line"},
    %Exit{id: "sorting_to_keep", to: "winnow_keep_line"},
    %Exit{id: "sorting_to_reclaim", to: "winnow_reclaim"},
    %Exit{id: "sorting_to_galley", to: "winnow_galley"}
  ]
}
