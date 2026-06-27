alias Shunt.World.Exit

%{
  id: "shunt9_power_relay",
  name: "Power Relay",

  short_description:
    "A humming substation feeding what's left of Shunt 9.",

  description:
    "Cables thick as a man's arm snake between rusted transformers, throwing off heat and a low electrical hum that never quite stops.",

  tags: [
    :infrastructure,
    :restricted
  ],

  graph_position: {100, 400},

  lattice: %{
    leads: [
      %{
        id: "grid_monitor_signal",
        requirements: [],
        text:
          "A live monitoring channel — routing every amp the relay draws through a single aggregation point.",
        on_intercept: [{:knowledge, "shunt9_grid_monitor_found"}]
      }
    ],
    filler: [
      %{
        weight: 3,
        text: "High EM interference from the transformers. The channel is mostly noise.",
        on_intercept: []
      },
      %{
        weight: 2,
        text: "A stray credit fragment washes through on a maintenance ping.",
        on_intercept: [{:scrip, 2}]
      }
    ]
  },

  npcs: [
    "shunt9_power_relay_coil"
  ],

  events: [
    "shunt9_power_relay_tap",
    "shunt9_power_relay_control_panel",
    "shunt9_power_relay_overloaded_duct"
  ],

  exits: [
    %Exit{
      id: "power_relay_to_bazaar",
      to: "shunt9_bazaar"
    }
  ]
}
