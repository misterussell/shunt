%{
  id: "standard_relay",
  name: "Standard Relay",
  tier_required: 1,
  inputs: %{
    "burnt_out_relay_board" => 1,
    "stripped_copper_coil" => 1,
    "flux_paste_tin" => 1
  },
  sell_value: 45,
  cred_gain: 1,
  heat_cost: 2,
  craft_text:
    "The board cleaned, the burnt traces lifted and re-laid in fresh solder. Boots first try. Holds under load.",
  sell_text: "A clean relay always finds a buyer. Things break constantly down here."
}
