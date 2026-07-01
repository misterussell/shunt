%Shunt.Repair.Repairable{
  id: "windlass_fitworks_relay",
  name: "Choked Fitworks Relay",
  location_id: "windlass_fitters_floor",
  initial_state: "broken",

  # A Collective relay the Authority throttled to keep the Fitworks readable. Bringing it back
  # flips a chunk of the floor off the Authority's grid — repairing it (repaired) pushes the
  # district `grid` fact toward :contested. The Collective supplies the parts; you supply the hands.
  inspect_tiers: [
    %{
      requirements: [],
      text:
        "One of the Collective's own relays, clamped dark. An Authority throttle-collar rides the line where it feeds the floor, choking it down to nothing so every reader here talks straight to the Ascent Office."
    },
    %{
      requirements: [{:has_item, "scrap_forged_soldering_iron"}],
      text:
        "The collar's crude but effective — it's cooking the relay slowly to keep it under. Strip the collar, reseat the relay, and this stretch of the Fitworks goes back to talking to the Collective instead of the Authority."
    }
  ],

  solutions: [
    %{
      id: "improvised",
      label: "Bridge Past the Collar",
      from: ["broken"],
      requirements: [{:has_item, "scrap_forged_soldering_iron"}],
      consumes: %{"improvised_relay" => 1},
      result_state: "patched",
      effects: [],
      outcome_text:
        "You bridge around the throttle-collar with a hand-wound relay. The line comes up thin but live, and a corner of the floor drops off the Authority's readers. It won't last, but it proves the grid can be taken back one relay at a time."
    },
    %{
      id: "standard",
      label: "Strip the Collar, Reseat It Clean",
      from: ["broken", "patched"],
      requirements: [{:has_item, "scrap_forged_soldering_iron"}],
      consumes: %{"standard_relay" => 1},
      result_state: "repaired",
      effects: [{:npc_loyalty, "windlass_fuse", 4}],
      outcome_text:
        "You cut the collar off and drop in a clean relay. The whole Fitters' Floor shifts under you — readers going quiet, the Collective's channels coming up strong. Fuse doesn't smile, but the crew works a little louder after. The grid war just moved a turn."
    }
  ],

  state_descriptions: %{
    "patched" =>
      "The Fitworks relay runs thin on a bridged line, a corner of the floor blinking off the Authority's readers. The fitters near it work a shade easier.",
    "repaired" =>
      "The Fitworks relay runs clean and strong, this whole stretch of floor talking to the Collective instead of the Ascent Office. The readers here are decoration now."
  }
}
