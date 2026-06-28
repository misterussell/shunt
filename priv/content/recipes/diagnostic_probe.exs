%{
  id: "diagnostic_probe",
  name: "Diagnostic Probe",
  tier_required: 1,
  inputs: %{"cracked_datachip" => 1, "frayed_optic_cable" => 1},
  sell_value: 35,
  cred_gain: 1,
  heat_cost: 1,
  craft_text:
    "A salvaged datachip wired to an optic lead. Touch it to a dead board and it tells you which part gave up first.",
  sell_text: "Anyone who fixes things for a living knows what a working probe is worth."
}
