%Shunt.Repair.Repairable{
  id: "shunt9_power_relay_generator",
  name: "Dead Backup Generator",
  location_id: "shunt9_power_relay",
  initial_state: "broken",

  # Higher Street Alchemy signals (tools on hand) read deeper into the fault. Cumulative:
  # each tier needs the one above it met first.
  inspect_tiers: [
    %{
      requirements: [],
      text: "It's dead. No hum, no heat. Just a cold steel box in the corner."
    },
    %{
      requirements: [{:has_item, "scrap_forged_soldering_iron"}],
      text:
        "You crack the panel. Scorch marks around the bus — this went out on an electrical fault, not a fuel one."
    },
    %{
      requirements: [{:has_item, "diagnostic_probe"}],
      text:
        "The probe walks the board and stops cold at the starter relay. Burned right through. Nothing past it ever saw power."
    },
    %{
      requirements: [{:has_item, "precision_toolkit"}],
      text:
        "Pull the relay and you find the why: a coolant line wept onto the contacts and cooked them. Replace the relay and the leak's still there — but it'll run."
    }
  ],

  solutions: [
    # TODO: [Chrome & Meat v1 — Milestone 4] Add an ADDITIVE solution gated on the first implant, so
    # chrome opens a better path on the generator's full repair without ever blocking the base ones:
    #   %{
    #     id: "live_bus_graft",
    #     label: "Work the Live Bus Barehanded",
    #     from: ["broken", "patched"],
    #     requirements: [{:has_implant, "lineman_graft"}],   # NO soldering iron needed — the graft is the tool
    #     consumes: %{"improvised_relay" => 1},              # cheaper than the standard/military paths
    #     result_state: "repaired",
    #     effects: [{:npc_loyalty, "shunt9_power_relay_coil", 4}],
    #     outcome_text: "..."  # you grip the hot bus with grafted hands and seat the relay live
    #   }
    # CRITICAL: this is a bonus shortcut only. The existing improvised/standard/military solutions must
    # remain fully usable by a chrome-less player — the power arc cannot depend on Chrome & Meat.
    %{
      id: "improvised",
      label: "Fit an Improvised Relay",
      from: ["broken"],
      requirements: [{:has_item, "scrap_forged_soldering_iron"}],
      consumes: %{"improvised_relay" => 1},
      result_state: "patched",
      effects: [],
      outcome_text:
        "You bridge the gap with the hand-wound relay. The generator catches, coughs, and settles into an uneven idle. The lights come up — not steady, but up."
    },
    %{
      id: "standard",
      label: "Fit a Standard Relay",
      from: ["broken", "patched"],
      requirements: [{:has_item, "scrap_forged_soldering_iron"}],
      consumes: %{"standard_relay" => 1},
      result_state: "repaired",
      effects: [{:npc_loyalty, "shunt9_power_relay_coil", 3}],
      outcome_text:
        "The clean board seats first try. The generator winds up smooth and holds there. Coil watches the load gauge stop swinging and gives you a short nod."
    },
    %{
      id: "military",
      label: "Fit a Military Relay",
      from: ["broken", "patched"],
      requirements: [
        {:has_item, "scrap_forged_soldering_iron"},
        {:has_item, "diagnostic_probe"}
      ],
      consumes: %{"military_relay" => 1},
      result_state: "repaired",
      effects: [
        {:npc_loyalty, "shunt9_power_relay_coil", 5},
        {:knowledge, "shunt9_relay_surplus_power"}
      ],
      outcome_text:
        "The shielded relay drops in like it was made for the slot. The generator comes up hard and stays there — overbuilt for the job, with headroom to spare. Coil whistles low. \"That'll outlast the building.\""
    }
  ],

  # When the backup is running, the whole bay reads differently. effective_description/2
  # swaps these in over the location's base text.
  state_descriptions: %{
    "patched" =>
      "Cables thick as a man's arm snake between rusted transformers. In the corner the backup generator runs rough, its light pulsing as the load swings — but it runs, and the bay no longer sits half in shadow.",
    "repaired" =>
      "Cables thick as a man's arm snake between rusted transformers, and the backup generator in the corner hums steady alongside them. Worklights throw hard white light across the floor; for the first time in a long while, the Power Relay looks like something that works."
  }
}
