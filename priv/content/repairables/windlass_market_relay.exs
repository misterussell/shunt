%Shunt.Repair.Repairable{
  id: "windlass_market_relay",
  name: "Throttled Market Relay",
  location_id: "windlass_coil_market",
  initial_state: "broken",

  # The relay that would let the market trade off the Authority's commerce registry. The Authority
  # keeps it throttled so every deal reads. Repairing it (repaired) pushes the district `grid` fact
  # toward :contested — a second front in the same war as the Fitworks relay.
  inspect_tiers: [
    %{
      requirements: [],
      text:
        "A commerce relay behind the stalls, collared dark like the one in the Fitworks. Every transaction on the floor is forced through the Authority's registry because this line was choked to make sure of it."
    },
    %{
      requirements: [{:has_item, "scrap_forged_soldering_iron"}],
      text:
        "Same throttle-collar, same crude job. Free this relay and the market gets a second set of channels — the ones the Authority can't price, which the Syndicate will love and the Authority will not."
    }
  ],

  solutions: [
    %{
      id: "improvised",
      label: "Bridge the Market Line",
      from: ["broken"],
      requirements: [{:has_item, "scrap_forged_soldering_iron"}],
      consumes: %{"improvised_relay" => 1},
      result_state: "patched",
      effects: [],
      outcome_text:
        "You bridge the collar and a run of stalls flickers off the registry. Somewhere a Syndicate ledger-keeper notices the gap in the Authority's read and starts thinking about what it's worth."
    },
    %{
      id: "standard",
      label: "Clear the Collar Proper",
      from: ["broken", "patched"],
      requirements: [{:has_item, "scrap_forged_soldering_iron"}],
      consumes: %{"standard_relay" => 1},
      result_state: "repaired",
      effects: [{:npc_loyalty, "windlass_sable", 4}],
      outcome_text:
        "You strip the collar and reseat the relay clean. Half the market drops off the Authority's registry at once, and the floor's prices split in two — the reader price and the real one. Sable finds you inside the hour to say the Ledger remembers who did it."
    }
  ],

  state_descriptions: %{
    "patched" =>
      "A run of market stalls trades off-registry now, bridged rough. The Authority's read of Coil Market has a hole in it, and the hole is growing.",
    "repaired" =>
      "Half of Coil Market runs off the Authority's registry entirely, a whole economy of prices the grid can't see. The readers over the stalls have quietly become the least trusted things on the floor."
  }
}
