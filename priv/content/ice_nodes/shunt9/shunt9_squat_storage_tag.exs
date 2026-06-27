%Shunt.Ghostwork.IceNode{
  id: "shunt9_squat_storage_tag",
  name: "Storage Unit Tag",
  family: "ice_derelict",
  location_id: "shunt9_player_squat",

  description:
    "The unit you sleep in still answers to the cargo network that ran this row — a dumb logistics tag bolted to the door frame, pinging an inventory that forgot it exists. Two locks deep, but neither one is current.",

  cool_threshold: 50,

  layers: [
    %{
      id: "tag_read",
      name: "Tag Handshake",
      progress_required: 5,
      trace_multiplier: 1.0,
      weakness: :spoof,
      reward: [{:scrip, 4}]
    },
    %{
      id: "manifest_row",
      name: "Manifest Row",
      progress_required: 7,
      trace_multiplier: 1.5,
      weakness: :decrypt,
      reward: [{:inventory, "stripped_copper_coil", 1}]
    }
  ]
}
