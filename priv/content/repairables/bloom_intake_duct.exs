%Shunt.Repair.Repairable{
  id: "bloom_intake_duct",
  name: "The Choked Intake Duct",
  location_id: "bloom_vent_run",
  initial_state: "broken",

  # The main intake carrying the Spire's bleed down into the Bloom. Its regulator's dead and the
  # duct is packed with years of soot, so the throat above runs cold and dim on half its petals.
  # Clearing it and reseating the regulator relay reopens the flow — the district `draw` fact
  # derives from this duct and the flare manifold together (patched/repaired -> drawing; both
  # repaired -> gorging). Higher Street Alchemy signals (tools on hand) read deeper into the choke.
  inspect_tiers: [
    %{
      requirements: [],
      text:
        "The intake is a dead throat of cold iron, the soot packed so hard it's gone to glass in places. The regulator housing is bolted shut behind it, and the petals downstream of it run dark. Whatever the Spire's venting, none of it is getting past here."
    },
    %{
      requirements: [{:has_item, "scrap_forged_soldering_iron"}],
      text:
        "You get the regulator housing open. It's not the soot that killed the flow — the regulator relay is pulled, the same clean pull you've seen before, and the duct choked cold behind a damper nobody would open again."
    },
    %{
      requirements: [{:has_item, "diagnostic_probe"}],
      text:
        "The probe reads it through: reseat the regulator relay and clear the glassed soot, and the damper swings open on its own draw. Do it rough and it'll gulp uneven; do it right and the intake runs wide, and the Bloom lights up behind it."
    }
  ],
  solutions: [
    %{
      id: "improvised",
      label: "Clear It Rough",
      from: ["broken"],
      requirements: [{:has_item, "scrap_forged_soldering_iron"}],
      consumes: %{"improvised_relay" => 1},
      result_state: "patched",
      effects: [],
      outcome_text:
        "You burn the glassed soot loose and wind the regulator a relay by hand. The damper shudders open and the intake pulls — uneven, gulping, but pulling. Downstream the dark petals flicker up warm, and the throat's roar climbs a note. It'll hold as long as nobody leans on it."
    },
    %{
      id: "standard",
      label: "Reseat the Regulator",
      from: ["broken", "patched"],
      requirements: [{:has_item, "scrap_forged_soldering_iron"}],
      consumes: %{"standard_relay" => 1},
      result_state: "repaired",
      effects: [],
      outcome_text:
        "You clear the duct to bare iron and seat a clean relay in the regulator. The damper swings wide on the Spire's own draw and the intake runs open and steady, the bleed pouring down into the Bloom the way it was built to. The petals blaze. So does the throat — and so, though nobody down here counts it, does the take up top."
    }
  ],
  state_descriptions: %{
    "patched" =>
      "The vent spine behind the petals, its main intake pulling rough now — the damper gulping open and shut, the ducts ticking with uneven heat. Warmer than it was, and brighter downstream, but you can hear it working too hard.",
    "repaired" =>
      "The vent spine behind the petals, its main intake running wide open, the Spire's bleed pouring down steady and the ducts singing with heat. The Bloom above runs on it — every petal lit, the throat roaring. Down here in the soot it's the one honest sound in the district."
  }
}
