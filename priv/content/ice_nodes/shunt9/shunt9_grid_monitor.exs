%Shunt.Ghostwork.IceNode{
  id: "shunt9_grid_monitor",
  name: "Grid Monitor",
  family: "ice_utility",
  location_id: "shunt9_power_relay",

  description:
    "A live monitoring system tracking every amp moving through the relay. The ICE is current-spec — updated regularly by whoever is supposed to maintain this. It hits back faster than the old systems.",

  requirements: [
    {:knows, "shunt9_grid_monitor_found"}
  ],

  cool_threshold: 70,

  layers: [
    %{
      id: "access",
      name: "Access Gate",
      progress_required: 8,
      trace_multiplier: 1.0,
      weakness: :spoof,
      reward: [{:scrip, 10}]
    },
    %{
      id: "draw_log",
      name: "Draw Log",
      progress_required: 10,
      trace_multiplier: 1.5,
      weakness: :decrypt,
      reward: [{:knowledge, "shunt9_grid_monitor_unauthorized_tap"}]
    },
    %{
      id: "source_trace",
      name: "Source Trace",
      progress_required: 12,
      trace_multiplier: 2.0,
      weakness: :backdoor,
      reward: [{:knowledge, "shunt9_grid_monitor_tap_location"}]
    }
  ]
}
