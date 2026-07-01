%Shunt.Repair.Repairable{
  id: "windlass_engine",
  name: "The Seized Windlass Engine",
  location_id: "windlass_winding_deck",
  initial_state: "broken",

  # The great screw-drive was sabotaged, not worn. Higher Street Alchemy signals (tools on hand)
  # read past the cover story into what was actually done to it. Cumulative: each tier needs the
  # one above it met first. Bringing the engine back (patched or repaired) restarts the Haul —
  # the district `haul` fact derives from this repairable alone.
  inspect_tiers: [
    %{
      requirements: [],
      text:
        "The drive is stopped dead and the deck around it radiates the heat of iron that turned for years and then didn't. The Authority's notice bolted to the housing says SEIZED — MECHANICAL FAILURE. The housing itself says otherwise, if you know how to read cooling metal."
    },
    %{
      requirements: [{:has_item, "scrap_forged_soldering_iron"}],
      text:
        "You get the inspection plate off. The main gearing's fine. What's wrong is a relay bank in the governor — pulled, not blown. Someone reached in and took the part that lets the drive spin up, then bolted the plate back and called it wear."
    },
    %{
      requirements: [{:has_item, "diagnostic_probe"}],
      text:
        "The probe confirms it: the governor's been gutted clean, the kind of clean that takes an authorized hand and a work order. Replace the relay bank and the engine spins up. Do it right and it holds. Either way, the freight climbs again — and the story about the stall stops holding."
    }
  ],

  solutions: [
    %{
      id: "improvised",
      label: "Wind It a Governor",
      from: ["broken"],
      requirements: [{:has_item, "scrap_forged_soldering_iron"}],
      consumes: %{"improvised_relay" => 2},
      result_state: "patched",
      effects: [{:npc_loyalty, "windlass_ratchet", 4}],
      outcome_text:
        "You wind a governor bank out of hand-made relays and drop it in. The screw shudders, catches, and begins to turn — rough, loud, and slower than it should, but turning. Freight climbs the coil for the first time in weeks. Ratchet watches it go up and doesn't say anything, which from Ratchet is a speech."
    },
    %{
      id: "standard",
      label: "Reseat the Governor",
      from: ["broken", "patched"],
      requirements: [{:has_item, "scrap_forged_soldering_iron"}],
      consumes: %{"military_relay" => 1},
      result_state: "repaired",
      effects: [{:npc_loyalty, "windlass_ratchet", 6}],
      outcome_text:
        "You seat a proper relay bank and true the governor to spec. The great screw comes up smooth and holds its speed, and the whole deck settles into the deep steady turn it was built for. The Slagworks crews feel it before they hear it. Word of who woke the engine — and what they found gutting it — is already climbing the coil."
    }
  ],

  state_descriptions: %{
    "patched" =>
      "The great screw-drive turns rough on a hand-wound governor — slow, loud, and holding. The deck shudders with it and the heat has teeth again, but the freight climbs. It'll run as long as nobody pushes it, and in the Windlass somebody always does.",
    "repaired" =>
      "The screw-drive turns smooth and enormous, trued to spec, the whole coil moving on it the way it was meant to. The heat is a wall and the noise is a weather, and under both the Windlass finally works — freight climbing steady from Slagfoot to the anchor, a city running on an engine somebody finally fixed right."
  }
}
