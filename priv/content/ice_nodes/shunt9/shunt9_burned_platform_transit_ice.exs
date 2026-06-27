%Shunt.Ghostwork.IceNode{
  id: "shunt9_burned_platform_transit_ice",
  name: "Transit Door ICE",
  family: "ice_security",
  location_id: "shunt9_burned_platform",

  description:
    "Active security ICE protecting a sealed transit door. Not old, not derelict — someone updated this. The lock is current-spec and it knows when it's being read.",

  requirements: [
    {:knows, "shunt9_burned_platform_transit_ice_found"}
  ],

  cool_threshold: 65,

  layers: [
    %{
      id: "challenge",
      name: "Access Challenge",
      progress_required: 8,
      trace_multiplier: 1.0,
      weakness: :spoof,
      reward: [{:scrip, 8}]
    },
    %{
      id: "lock_mechanism",
      name: "Lock Mechanism",
      progress_required: 11,
      trace_multiplier: 1.5,
      weakness: :decrypt,
      reward: [{:knowledge, "crossgate_transit_signal"}]
    },
    %{
      id: "emergency_override",
      name: "Emergency Override",
      progress_required: 14,
      trace_multiplier: 2.0,
      weakness: :backdoor,
      reward: [{:knowledge, "crossgate_transit_unlocked"}]
    }
  ]
}
