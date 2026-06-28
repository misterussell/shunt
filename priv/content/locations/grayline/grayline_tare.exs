alias Shunt.World.Exit

%{
  id: "grayline_tare",
  name: "The Tare",

  short_description:
    "The Grayline's market. Named for what the grid weighs and throws away.",

  description:
    "A reclaimed cargo hall the Authority logs as empty mass — the tare, the weight you subtract before the count. Stalls run the length of it under spliced Midgrid light, selling Midgrid goods at Underbelly prices and Underbelly goods at Midgrid markups. Everyone here climbed out of something. Nobody asks from where. The trade is loud and the watching is quiet.",

  tags: [
    :midgrid,
    :market,
    :social
  ],

  graph_position: {1640, -310},

  lattice: %{
    leads: [
      %{
        id: "tare_independent_chatter",
        requirements: [],
        text:
          "Under the haggling, a thread of careful talk — a name passed low between stalls, someone who writes paper outside the Court and hasn't been collected for it.",
        on_intercept: [{:rumor, "cal_was_court"}]
      }
    ],
    filler: [
      %{
        weight: 3,
        text: "A churn of bartering and till-pings, too many voices to pull one clean.",
        on_intercept: []
      },
      %{
        weight: 2,
        text: "A stall's credit feed runs unsecured for a breath. You skim the spill.",
        on_intercept: [{:scrip, 3}]
      },
      %{
        weight: 2,
        text:
          "Two sellers settling a trade in the open. Nothing for you in it — but you hear how the Grayline keeps its accounts.",
        on_intercept: []
      }
    ]
  },

  events: [
    "grayline_tare_independent"
  ],

  exits: [
    %Exit{
      id: "tare_to_sortway",
      to: "grayline_sortway"
    },
    %Exit{
      id: "tare_to_warren",
      to: "grayline_warren"
    },
    %Exit{
      id: "tare_to_echo_court",
      to: "grayline_echo_court"
    },
    %Exit{
      id: "tare_to_glassline",
      to: "grayline_glassline"
    },
    %Exit{
      id: "tare_to_cutaway",
      to: "grayline_cutaway",
      requirements: [
        {:knows, "cutaway_found"}
      ]
    }
  ]
}
