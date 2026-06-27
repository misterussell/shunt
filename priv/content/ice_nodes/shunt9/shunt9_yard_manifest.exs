%Shunt.Ghostwork.IceNode{
  id: "shunt9_yard_manifest",
  name: "Yard Manifest",
  family: "ice_derelict",
  location_id: "shunt9_scrap_yard",

  description:
    "An old logistics system from when this yard ran official inventory. The ICE is degraded and inconsistent — it forgets it's being poked, then remembers all at once.",

  requirements: [
    {:knows, "shunt9_yard_manifest_found"}
  ],

  cool_threshold: 45,

  layers: [
    %{
      id: "index",
      name: "Manifest Index",
      progress_required: 5,
      trace_multiplier: 1.0,
      weakness: :spoof,
      reward: [{:scrip, 12}]
    },
    %{
      id: "archive",
      name: "Deep Archive",
      progress_required: 7,
      trace_multiplier: 2.0,
      weakness: :decrypt,
      reward: [{:knowledge, "shunt9_scrap_yard_old_cache"}]
    }
  ]
}
