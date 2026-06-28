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
      trace_multiplier: 1.0,
      reward: [{:scrip, 8}],
      subroutines: [
        %{id: "challenge_core", key: :spoof, threat: :barrier, progress_required: 8}
      ]
    },
    %{
      id: "lock_mechanism",
      name: "Lock Mechanism",
      trace_multiplier: 1.5,
      reward: [{:knowledge, "crossgate_transit_signal"}],
      subroutines: [
        %{id: "lock_mechanism_core", key: :decrypt, threat: :barrier, progress_required: 11}
      ]
    },
    %{
      id: "emergency_override",
      name: "Emergency Override",
      trace_multiplier: 2.0,
      reward: [{:knowledge, "crossgate_transit_unlocked"}],
      subroutines: [
        %{id: "emergency_override_core", key: :backdoor, threat: :barrier, progress_required: 14}
      ]
    }
  ]
}
