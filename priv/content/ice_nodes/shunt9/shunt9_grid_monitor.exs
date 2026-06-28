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
      trace_multiplier: 1.0,
      reward: [{:scrip, 10}],
      subroutines: [
        %{id: "access_core", key: :spoof, threat: :barrier, progress_required: 8}
      ]
    },
    %{
      id: "draw_log",
      name: "Draw Log",
      trace_multiplier: 1.5,
      reward: [{:knowledge, "shunt9_grid_monitor_unauthorized_tap"}],
      subroutines: [
        %{id: "draw_log_core", key: :decrypt, threat: :barrier, progress_required: 10}
      ]
    },
    %{
      id: "source_trace",
      name: "Source Trace",
      trace_multiplier: 2.0,
      reward: [{:knowledge, "shunt9_grid_monitor_tap_location"}],
      subroutines: [
        %{id: "source_trace_core", key: :backdoor, threat: :barrier, progress_required: 12}
      ]
    }
  ]
}
