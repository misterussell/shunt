%Shunt.Ghostwork.IceNode{
  id: "crossgate_counting_house_ledger",
  name: "Syndicate Ledger",
  family: "ice_security",
  location_id: "crossgate_counting_house",

  description:
    "The Syndicate's financial records for The Crossgate, protected by the most current security ICE in the building. Cracking it is a significant risk — this is their own house. The rewards reflect what's at stake.",

  requirements: [
    {:knows, "crossgate_counting_house_ledger_found"}
  ],

  cool_threshold: 75,

  layers: [
    %{
      id: "outer_lock",
      name: "Outer Lock",
      progress_required: 10,
      trace_multiplier: 1.0,
      weakness: :spoof,
      reward: [{:scrip, 20}]
    },
    %{
      id: "ledger_access",
      name: "Ledger Access",
      progress_required: 13,
      trace_multiplier: 1.5,
      weakness: :decrypt,
      reward: [{:knowledge, "crossgate_syndicate_cut_structure"}]
    },
    %{
      id: "debt_registry",
      name: "Debt Registry",
      progress_required: 16,
      trace_multiplier: 2.25,
      weakness: :backdoor,
      reward: [{:knowledge, "crossgate_syndicate_debt_registry"}]
    }
  ]
}
