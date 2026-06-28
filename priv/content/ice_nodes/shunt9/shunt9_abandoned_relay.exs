%Shunt.Ghostwork.IceNode{
  id: "shunt9_abandoned_relay",
  name: "Abandoned Relay",
  family: "ice_maintenance",
  location_id: "shunt9_maintenance_tunnel",

  description:
    "An old maintenance relay still listening on a dead frequency. Its ICE is the cheap factory kind — slow, but it remembers when it's been poked.",

  requirements: [
    {:knows, "shunt9_abandoned_relay_found"}
  ],

  cool_threshold: 60,

  layers: [
    %{
      id: "handshake",
      name: "Access Handshake",
      trace_multiplier: 1.0,
      reward: [{:inventory, "maintenance_log", 1}],
      subroutines: [
        %{id: "handshake_core", key: :spoof, threat: :barrier, progress_required: 6}
      ]
    },
    %{
      id: "archive",
      name: "Log Archive",
      trace_multiplier: 1.5,
      reward: [{:knowledge, "maintenance_log_decoded"}],
      subroutines: [
        %{id: "archive_core", key: :decrypt, threat: :barrier, progress_required: 9}
      ]
    }
  ]
}
