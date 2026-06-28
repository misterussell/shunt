%Shunt.Repair.Repairable{
  id: "grayline_warren_power_tap",
  name: "Burned-Out Power Tap",
  location_id: "grayline_warren",
  initial_state: "broken",

  # The Warren steals its power off the Midgrid main through an unlicensed tap. Higher Street
  # Alchemy signals (tools on hand) read deeper into why it died. Cumulative: each tier needs
  # the one above it met first.
  inspect_tiers: [
    %{
      requirements: [],
      text:
        "The tap is dead. Half the Warren's running on hand-lamps and the heat exchangers have gone cold. The splice into the Midgrid main is a charred lump nobody wants to touch."
    },
    %{
      requirements: [{:has_item, "scrap_forged_soldering_iron"}],
      text:
        "You get the cover off. The tap's been overdrawn — too many bunkrooms pulling through one bridge that was never rated for it. The bridge cooked."
    },
    %{
      requirements: [{:has_item, "diagnostic_probe"}],
      text:
        "The probe finds it: the relay in the bridge is slagged, and the line past it shorted to the housing. Replace the relay, isolate the short, and the Warren has power again — quietly, the way the Warren likes things."
    }
  ],

  solutions: [
    %{
      id: "improvised",
      label: "Bridge It Rough",
      from: ["broken"],
      requirements: [{:has_item, "scrap_forged_soldering_iron"}],
      consumes: %{"improvised_relay" => 1},
      result_state: "patched",
      effects: [],
      outcome_text:
        "You bridge the tap with a hand-wound relay. The lamps come up uneven and the exchangers tick back to life. It'll hold — as long as nobody runs the Warren too hard, and somebody always does."
    },
    %{
      id: "standard",
      label: "Reseat the Bridge",
      from: ["broken", "patched"],
      requirements: [{:has_item, "scrap_forged_soldering_iron"}],
      consumes: %{"standard_relay" => 1},
      result_state: "repaired",
      effects: [{:npc_loyalty, "grayline_della", 4}],
      outcome_text:
        "You drop in a clean relay and isolate the short proper. The tap settles into a steady draw and the Warren warms through for the first time in weeks. Word of who fixed it travels the corridors before you've packed your kit. Della hears it among the first."
    }
  ],

  # When the tap is live, the whole Warren reads differently. effective_description/2 swaps
  # these in over the location's base text.
  state_descriptions: %{
    "patched" =>
      "A residential stack the grid decommissioned and never reclaimed. The unlicensed tap is bridged rough and the lamps run uneven, but the corridors are lit and the heat exchangers are ticking again. People move easier when the Warren's warm.",
    "repaired" =>
      "A residential stack the grid decommissioned and never reclaimed, running steady on a tap somebody finally fixed right. The lamps hold even, the exchangers hum low, and for the first time the Warren feels less like a place people are hiding and more like a place people live."
  }
}
