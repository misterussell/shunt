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
      trace_multiplier: 1.0,
      reward: [{:scrip, 20}],
      subroutines: [
        %{id: "outer_lock_core", key: :spoof, threat: :barrier, progress_required: 10}
      ]
    },
    %{
      id: "ledger_access",
      name: "Ledger Access",
      trace_multiplier: 1.5,
      reward: [{:knowledge, "crossgate_syndicate_cut_structure"}],
      subroutines: [
        %{id: "ledger_access_core", key: :decrypt, threat: :barrier, progress_required: 13}
      ]
    },
    %{
      id: "debt_registry",
      name: "Debt Registry",
      trace_multiplier: 2.25,
      reward: [{:knowledge, "crossgate_syndicate_debt_registry"}],
      subroutines: [
        %{id: "debt_registry_core", key: :backdoor, threat: :barrier, progress_required: 16}
      ]
    }
  ]
}
