%Shunt.Ghostwork.IceNode{
  id: "shunt9_salvage_grid",
  name: "Salvage Auth Grid",
  family: "ice_collective",
  location_id: "shunt9_scrap_yard",

  description:
    "A Latticework Collective auth grid bolted onto the yard's intake, deciding which chassis get logged as scrap and which quietly walk. Newer than anything else in the heaps — and it watches the way you work. Its second layer runs three subroutines at once: a watchdog that climbs the longer it's left breathing, a bolt that only cares about a clean signature, and a canary that screams if you force the wrong key.",

  requirements: [
    {:knows, "shunt9_salvage_grid_found"}
  ],

  cool_threshold: 60,

  layers: [
    %{
      id: "intake",
      name: "Intake Bolt",
      trace_multiplier: 1.0,
      reward: [{:scrip, 10}],
      subroutines: [
        %{id: "intake_bolt", key: :spoof, threat: :barrier, progress_required: 6}
      ]
    },
    %{
      id: "auth_grid",
      name: "Auth Grid",
      trace_multiplier: 1.5,
      reward: [{:scrip, 25}, {:knowledge, "shunt9_salvage_grid_cracked"}],
      subroutines: [
        %{id: "watchdog", key: :decrypt, threat: :sentry, progress_required: 6},
        %{id: "load_bolt", key: :spoof, threat: :barrier, progress_required: 8},
        %{id: "canary", key: :backdoor, threat: :trap, progress_required: 5}
      ]
    }
  ]
}
