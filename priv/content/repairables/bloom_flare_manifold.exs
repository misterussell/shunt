%Shunt.Repair.Repairable{
  id: "bloom_flare_manifold",
  name: "The Seized Flare Manifold",
  location_id: "bloom_vent_run",
  initial_state: "broken",

  # The manifold that splits the intake's bleed out to the four petals. Seized on a dead relay,
  # so even when the intake pulls, the flare can't share it evenly. Feeds the district `draw` fact
  # alongside bloom_intake_duct: both fully repaired throws draw to :gorging. No location-text swap
  # (the intake carries the Vent Run's state descriptions).
  inspect_tiers: [
    %{
      requirements: [],
      text:
        "The manifold is the iron flower the intake feeds — four throats splitting the bleed out to the petals. It's seized solid, all four dampers locked, and the heat that does get through pools wrong: one petal roasting, the next gone cold."
    },
    %{
      requirements: [{:has_item, "scrap_forged_soldering_iron"}],
      text:
        "You get to the splitter relay. It's slagged — overdrawn and left to cook, the kind of neglect that reads as nobody up top wanting to pay for the part. Replace it and the dampers balance again."
    },
    %{
      requirements: [{:has_item, "precision_toolkit"}],
      text:
        "The toolkit trues it: reseat the splitter relay and re-time the four dampers, and the manifold shares the intake's draw clean across every petal. Rough work leaves it lopsided; precise work makes the whole flower burn even."
    }
  ],
  solutions: [
    %{
      id: "improvised",
      label: "Free the Dampers",
      from: ["broken"],
      requirements: [{:has_item, "scrap_forged_soldering_iron"}],
      consumes: %{"improvised_relay" => 1},
      result_state: "patched",
      effects: [],
      outcome_text:
        "You knock the dampers loose and bridge the splitter a rough relay. The manifold shares the bleed again — lopsided, one petal always hungrier than the rest, but sharing. The cold petals warm through unevenly, and the Bloom stops looking half-dead."
    },
    %{
      id: "standard",
      label: "True the Manifold",
      from: ["broken", "patched"],
      requirements: [{:has_item, "precision_toolkit"}],
      consumes: %{"standard_relay" => 1},
      result_state: "repaired",
      effects: [],
      outcome_text:
        "You seat a clean splitter relay and re-time all four dampers to spec. The manifold breathes even, every petal drawing its full share, the whole flower burning at once. With the intake wide behind it, the Bloom runs at the top of its lungs — brightest it's ever been, and taking the most."
    }
  ],
  state_descriptions: %{}
}
