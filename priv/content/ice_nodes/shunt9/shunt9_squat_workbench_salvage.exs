%Shunt.Ghostwork.IceNode{
  id: "shunt9_squat_workbench_salvage",
  name: "Workbench Salvage",
  family: "ice_derelict",
  location_id: "shunt9_player_squat",

  description:
    "A dead handheld you pulled off a scrap run, still on the bench. The ICE is the cheap factory kind — barely a lock at all, but it's a place to practice without anyone watching.",

  cool_threshold: 40,

  layers: [
    %{
      id: "wakeup",
      name: "Wake Signal",
      trace_multiplier: 1.0,
      reward: [{:scrip, 5}],
      subroutines: [
        %{id: "wakeup_core", key: :spoof, threat: :barrier, progress_required: 5}
      ]
    }
  ]
}
