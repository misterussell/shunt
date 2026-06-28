alias Shunt.World.Exit

%{
  id: "grayline_echo_court",
  name: "The Echo Court",

  short_description:
    "The faction's front. A records office that decides who gets to be real.",

  description:
    "Once a Midgrid records bureau — the kind with a counter, a number system, and a long wait. The Court kept all of it. You take a chit. You sit on a bench worn by people who came before you. When your number comes up, someone pleasant explains, in the calm voice of administration, exactly what it costs to acquire a past the grid will believe. They don't think of it as forgery. They think of it as intake done properly, by people the grid forgot to staff.",

  tags: [
    :midgrid,
    :social
  ],

  graph_position: {1800, -350},

  lattice: %{
    leads: [
      %{
        id: "court_template_loop",
        requirements: [],
        text:
          "Behind the counter chatter, a maintenance loop addresses a store you can't see — template blocks, versioned and locked, racked somewhere past the back wall.",
        on_intercept: [{:rumor, "templates_in_the_stacks"}]
      }
    ],
    filler: [
      %{
        weight: 3,
        text: "Queue tones and the rustle of paper that means more than paper. Nothing loose.",
        on_intercept: []
      },
      %{
        weight: 2,
        text: "A clerk's terminal flushes a session. A few credit fragments fall out with it.",
        on_intercept: [{:scrip, 4}]
      }
    ]
  },

  npcs: [
    "grayline_quire",
    "grayline_sana"
  ],

  exits: [
    %Exit{
      id: "echo_court_to_tare",
      to: "grayline_tare"
    },
    %Exit{
      id: "echo_court_to_stacks",
      to: "grayline_the_stacks",
      requirements: [
        {:knows, "echo_forge_method"}
      ]
    }
  ]
}
