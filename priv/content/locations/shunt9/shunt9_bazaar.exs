alias Shunt.World.Exit

%{
  id: "shunt9_bazaar",
  name: "Shunt 9 Bazaar",

  short_description:
    "The beating heart of Shunt 9.",

  description:
    "Hundreds of stalls crowd the abandoned transit platform, lit by salvaged work lamps and the glow of a dozen black-market terminals.",

  tags: [
    :market,
    :underbelly
  ],

  graph_position: {250, 400},

  lattice: %{
    leads: [
      %{
        id: "vendor_squeeze_signal",
        requirements: [],
        text:
          "Under the market's open chatter, a tight little data loop — stall IDs and a recurring debit none of the vendors will name out loud.",
        on_intercept: [{:rumor, "vendor_squeeze"}]
      }
    ],
    filler: [
      %{
        weight: 3,
        text: "A wash of haggling and terminal pings, too many voices to pull one clear.",
        on_intercept: []
      },
      %{
        weight: 2,
        text: "Loose credit fragments drift past on an unsecured till feed.",
        on_intercept: [{:scrip, 3}]
      },
      %{
        weight: 2,
        text: "Two stalls negotiating a trade in the clear. Nothing you can use — but you hear how the market breathes.",
        on_intercept: []
      }
    ]
  },

  npcs: [
    "shunt9_bazaar_juno",
    "shunt9_bazaar_wrench",
    "shunt9_bazaar_nickel"
  ],

  exits: [
    %Exit{
      id: "bazaar_to_scrap_yard",
      to: "shunt9_scrap_yard"
    },
    %Exit{
      id: "bazaar_to_supplier_drop",
      to: "shunt9_supplier_drop"
    },
    %Exit{
      id: "bazaar_to_cargo_chute",
      to: "shunt9_cargo_chute",
      requirements: [
        {:rep_at_least, "juno", :trust, 20}
      ]
    },
    %Exit{
      id: "bazaar_to_food_stalls",
      to: "shunt9_food_stalls"
    },
    %Exit{
      id: "bazaar_to_power_relay",
      to: "shunt9_power_relay",
      requirements: [
        {:knows, "power_relay_entrance"}
      ]
    },
    %Exit{
      id: "bazaar_to_rooks_desk",
      to: "shunt9_rooks_desk"
    },
    %Exit{
      id: "bazaar_to_burned_platform",
      to: "shunt9_burned_platform"
    }
  ]
}
