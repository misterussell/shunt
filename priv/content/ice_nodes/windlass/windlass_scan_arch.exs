%Shunt.Ghostwork.IceNode{
  id: "windlass_scan_arch",
  name: "Permit Registry",
  family: "ice_authority",
  location_id: "windlass_ascent_office",

  description:
    "The brain behind the scan arch — the registry that issues the Windlass's permits and keeps its purge lists. This is the hardest ICE in the district, layered with sentries that bleed you and traps that punish the first wrong move. But it's where the Authority keeps its paperwork, and paperwork is how a lie gets caught. Somewhere in here is the order that stopped the freight.",

  requirements: [
    {:knows, "windlass_scan_arch_found"}
  ],

  cool_threshold: 80,

  layers: [
    %{
      id: "permit_face",
      name: "Permit Face",
      trace_multiplier: 1.0,
      reward: [{:scrip, 16}],
      subroutines: [
        %{id: "permit_face_core", key: :spoof, threat: :barrier, progress_required: 11}
      ]
    },
    %{
      id: "sentinel",
      name: "Sentinel Layer",
      trace_multiplier: 1.5,
      reward: [{:scrip, 14}],
      subroutines: [
        %{id: "sentinel_a", key: :decrypt, threat: :sentry, progress_required: 12},
        %{id: "sentinel_b", key: :spoof, threat: :trap, progress_required: 10}
      ]
    },
    %{
      id: "order_store",
      name: "Order Store",
      trace_multiplier: 2.5,
      reward: [{:rumor, "windlass_authority_order"}, {:scrip, 22}],
      subroutines: [
        %{id: "order_store_core", key: :backdoor, threat: :sentry, progress_required: 14}
      ]
    }
  ]
}
