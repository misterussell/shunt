%Shunt.Ghostwork.IceNode{
  id: "windlass_market_registry",
  name: "Commerce Registry Node",
  family: "ice_authority",
  location_id: "windlass_coil_market",

  description:
    "The Authority's read on every deal in Coil Market — a fat, slow registry node that logs who bought what from whom. It's not fast ICE, but it's layered thick with the kind of traps that punish a wrong tool. Get inside and the market's whole shadow-economy is yours to read.",

  requirements: [
    {:knows, "windlass_market_registry_found"}
  ],

  cool_threshold: 70,

  layers: [
    %{
      id: "ledger_face",
      name: "Ledger Face",
      trace_multiplier: 1.0,
      reward: [{:scrip, 14}],
      subroutines: [
        %{id: "ledger_face_core", key: :decrypt, threat: :barrier, progress_required: 10}
      ]
    },
    %{
      id: "audit_trap",
      name: "Audit Trap",
      trace_multiplier: 1.5,
      reward: [{:scrip, 12}],
      subroutines: [
        %{id: "audit_trap_core", key: :spoof, threat: :trap, progress_required: 12}
      ]
    },
    %{
      id: "correlation",
      name: "Correlation Store",
      trace_multiplier: 2.0,
      reward: [{:knowledge, "windlass_market_registry_cracked"}, {:scrip, 20}],
      subroutines: [
        %{id: "correlation_core", key: :backdoor, threat: :sentry, progress_required: 13}
      ]
    }
  ]
}
