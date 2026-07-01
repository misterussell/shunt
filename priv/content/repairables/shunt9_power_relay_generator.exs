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
    # ADDITIVE chrome path: a Lineman's Graft lets you seat a relay on the live bus, no soldering iron
    # and only an improvised relay. A bonus shortcut, never a gate — the improvised/standard/military
    # solutions below remain fully usable without any chrome, so the power arc never depends on it.
    %{
      id: "live_bus_graft",
      label: "Work the Live Bus (Lineman's Graft)",
      from: ["broken", "patched"],
      requirements: [{:has_implant, "lineman_graft"}],
      consumes: %{"improvised_relay" => 1},
      result_state: "repaired",
      effects: [{:npc_loyalty, "shunt9_power_relay_coil", 4}],
      outcome_text:
        "You don't cut the power. You reach into it — grafted hands closing on the live bus, the weave eating the current, the servo holding your grip dead steady while you seat the relay hot. The generator winds up hard and holds. Coil stares. \"You're insane,\" he says, almost admiring. \"But it's done.\""
    },
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
