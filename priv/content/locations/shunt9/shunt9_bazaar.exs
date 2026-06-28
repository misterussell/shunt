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

  # District-level ambient line, deepest met tier wins. Reflects power coming back to Shunt 9 —
  # additive flavor over the base description, distinct from any single repairable's state text.
  atmosphere: [
    %{
      requirements: [],
      text:
        "Half the stalls run dark, their keepers trading by the light of whatever they can carry and packing up early when it gutters."
    },
    %{
      requirements: [{:district, "shunt9", :power, :>=, :online}],
      text:
        "The worklight strings are lit end to end now, and the crowd's thicker for it — more voices, harder haggling, the hum of benches that finally have a clean line to draw on."
    }
  ],

  graph_position: {250, 400},

  lattice: %{
    leads: [
      %{
        id: "maskchip_skim",
        requirements: [],
        text:
          "A vendor's terminal keeps reauthing against an uptown handshake it shouldn't have. You copy the routine before it rotates — a working Maskchip.",
        on_intercept: [{:inventory, "maskchip", 1}, {:knowledge, "maskchip_skimmed"}]
      },
      %{
        id: "shard_reader_skim",
        requirements: [],
        text:
          "Someone left a Shard Reader looping on an open till feed, chewing through receipts it already cracked. You lift the program and let the feed forget you.",
        on_intercept: [{:inventory, "shard_reader", 1}, {:knowledge, "shard_reader_skimmed"}]
      },
      %{
        id: "ghostkey_skim",
        requirements: [{:has_program, :spoof}],
        text:
          "A back-stall fixer is selling forged maintenance keys to anyone whose mask already checks out. Yours does. You walk with a Ghostkey.",
        on_intercept: [{:inventory, "ghostkey", 1}, {:knowledge, "ghostkey_skimmed"}]
      },
      %{
        id: "signal_knife_skim",
        requirements: [{:has_program, :decrypt}],
        text:
          "The same fixer watches you read a cipher the slow way and slides a Signal Knife across the counter. Faster. Louder. Your problem now.",
        on_intercept: [{:inventory, "signal_knife", 1}, {:knowledge, "signal_knife_skimmed"}]
      },
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
    "shunt9_bazaar_nickel",
    # Volt only hauls his bench down once the grid is live — appears when district power is online.
    %{
      id: "shunt9_bazaar_volt",
      requirements: [{:district, "shunt9", :power, :>=, :online}]
    }
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
