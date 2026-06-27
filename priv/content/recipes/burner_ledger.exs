%{
  id: "burner_ledger",
  name: "Burner Ledger",
  tier_required: 0,
  inputs: %{"burner_sim_stack" => 1, "forged_credential_stub" => 1},
  sell_value: 40,
  cred_gain: 1,
  heat_cost: 3,
  craft_text:
    "A burner SIM paired to a half-forged credential — enough to open a ledger no one can trace.",
  sell_text: "Burner hardware moves fast and cheap in the Underbelly."
}
