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
      progress_required: 6,
      trace_multiplier: 1.0,
      weakness: :spoof,
      reward: [{:inventory, "maintenance_log", 1}]
    },
    %{
      id: "archive",
      name: "Log Archive",
      progress_required: 9,
      trace_multiplier: 1.5,
      weakness: :decrypt,
      reward: [{:knowledge, "maintenance_log_decoded"}]
    }
  ]
}
