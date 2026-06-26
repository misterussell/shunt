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

  exits: [
    %Exit{
      id: "bazaar_to_scrap_yard",
      to: "shunt9_scrap_yard"
    },
    %Exit{
      id: "bazaar_to_food_stalls",
      to: "shunt9_food_stalls"
    },
    %Exit{
      id: "bazaar_to_power_relay",
      to: "shunt9_power_relay",
      requirements: [
        # TODO: migrate to the unified knowledge keyword: {:knows, "power_relay_entrance"}
        {:flag, :knows_power_relay_entrance}
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
