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
      trace_multiplier: 1.0,
      reward: [{:scrip, 4}],
      subroutines: [
        %{id: "tag_read_core", key: :spoof, threat: :barrier, progress_required: 5}
      ]
    },
    %{
      id: "manifest_row",
      name: "Manifest Row",
      trace_multiplier: 1.5,
      reward: [{:inventory, "stripped_copper_coil", 1}],
      subroutines: [
        %{id: "manifest_row_core", key: :decrypt, threat: :barrier, progress_required: 7}
      ]
    }
  ]
}
