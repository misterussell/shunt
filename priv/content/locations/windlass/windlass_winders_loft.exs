alias Shunt.World.Exit

%{
  id: "windlass_winders_loft",
  name: "The Winder's Loft",

  # Territory premises — class 3, the Node-tier home the Collective sets you up in. Relocating here
  # requires the Collective to have offered it (windlass_drift_loft). Its class 3 is what unlocks the
  # signal_tap module, whose income scales with the district grid fact.
  premises_class: 3,
  relocation: %{
    cost: %{scrip: 800, cred: 60},
    requirements: [{:knows, "windlass_loft_offered"}]
  },

  short_description:
    "A relay-fitter's loft over the Fitworks — yours, if you can hold it.",

  description:
    "A disused fitting loft above the benches, all hard lines and clean grounding — a place built to work on the grid, wired straight into it. The Collective cleared it for you: a cot, a bench, a hard tap off the district trunk that most people in the Windlass would kill to have. It's the first place you've had that the grid treats as a fixture instead of a stray. From the window the whole coil drops away below you.",

  tags: [
    :midgrid,
    :home,
    :safe,
    :latticework
  ],

  graph_position: {2480, -1120},

  events: [],

  exits: [
    %Exit{
      id: "winders_loft_to_fitters_floor",
      to: "windlass_fitters_floor"
    }
  ]
}
