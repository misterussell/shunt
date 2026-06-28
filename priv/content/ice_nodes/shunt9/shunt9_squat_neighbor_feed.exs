%Shunt.Ghostwork.IceNode{
  id: "shunt9_squat_neighbor_feed",
  name: "Neighbor's Feed",
  family: "ice_derelict",
  location_id: "shunt9_player_squat",

  description:
    "Somebody two units down runs a tapped feed off the row's old service line, and the bleed reaches your wall. Older lock, but layered — they cared enough to bury a backdoor under it. By now you can read this kind of ICE in your sleep.",

  cool_threshold: 60,

  layers: [
    %{
      id: "bleed",
      name: "Signal Bleed",
      trace_multiplier: 1.5,
      reward: [{:scrip, 6}],
      subroutines: [
        %{id: "bleed_core", key: :decrypt, threat: :barrier, progress_required: 6}
      ]
    },
    %{
      id: "buried_door",
      name: "Buried Backdoor",
      trace_multiplier: 2.0,
      reward: [{:scrip, 12}],
      subroutines: [
        %{id: "buried_door_core", key: :backdoor, threat: :barrier, progress_required: 8}
      ]
    }
  ]
}
