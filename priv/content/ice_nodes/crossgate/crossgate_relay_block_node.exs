%Shunt.Ghostwork.IceNode{
  id: "crossgate_relay_block_node",
  name: "Collective Node",
  family: "ice_collective",
  location_id: "crossgate_relay_block",

  description:
    "A Latticework Collective node installed inside the relay infrastructure. The ICE is adaptive — it watches how you probe and adjusts. The first time through this family you'll be fighting blind. The second time, it starts to make sense.",

  requirements: [
    {:knows, "crossgate_relay_block_node_found"}
  ],

  cool_threshold: 55,

  layers: [
    %{
      id: "mask",
      name: "Identity Mask",
      trace_multiplier: 1.0,
      reward: [{:scrip, 15}],
      subroutines: [
        %{id: "mask_core", key: :decrypt, threat: :barrier, progress_required: 9}
      ]
    },
    %{
      id: "routing",
      name: "Routing Table",
      trace_multiplier: 1.75,
      reward: [{:knowledge, "crossgate_collective_routing_fragment"}],
      subroutines: [
        %{id: "routing_core", key: :spoof, threat: :barrier, progress_required: 12}
      ]
    }
  ]
}
