%Shunt.Ghostwork.IceNode{
  id: "windlass_fitworks_ice",
  name: "Fitworks Relay Node",
  family: "ice_authority",
  location_id: "windlass_fitters_floor",

  description:
    "The Authority node that keeps the Fitters' Floor readable — the reader-trunk for half the benches. It's current-spec Kaspav ICE: it watches back, and it doesn't forgive a slow hand. Cracking it blinds this stretch of the floor and shifts the grid war a turn in the Collective's favour.",

  requirements: [
    {:knows, "windlass_fitworks_ice_found"}
  ],

  cool_threshold: 65,

  layers: [
    %{
      id: "handshake",
      name: "Reader Handshake",
      trace_multiplier: 1.0,
      reward: [{:scrip, 12}],
      subroutines: [
        %{id: "handshake_core", key: :spoof, threat: :barrier, progress_required: 9}
      ]
    },
    %{
      id: "watchdog",
      name: "Watchdog",
      trace_multiplier: 1.5,
      reward: [{:scrip, 10}],
      subroutines: [
        %{id: "watchdog_core", key: :decrypt, threat: :sentry, progress_required: 11}
      ]
    },
    %{
      id: "trunk",
      name: "Reader Trunk",
      trace_multiplier: 2.0,
      reward: [{:knowledge, "windlass_fitworks_ice_cracked"}, {:scrip, 15}],
      subroutines: [
        %{id: "trunk_core", key: :backdoor, threat: :barrier, progress_required: 12}
      ]
    }
  ]
}
