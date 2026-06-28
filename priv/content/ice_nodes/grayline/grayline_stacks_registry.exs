%Shunt.Ghostwork.IceNode{
  id: "grayline_stacks_registry",
  name: "Registry Write-Head",
  family: "ice_security",
  location_id: "grayline_the_stacks",

  description:
    "The terminal wired into the Midgrid registry — current-spec on the face, soft in the back where the Court never expected a client to reach. Cal showed you the seam. Feed it a stub shaped like a Court template and it will write you into the grid's own memory. Open it clean and you walk the line as a citizen. Trip it and the write lands flagged, and Reyes meets you at the Holdover.",

  requirements: [
    {:knows, "echo_forge_method"},
    {:has_item, "forgers_stub"}
  ],

  cool_threshold: 80,

  layers: [
    %{
      id: "intake_shell",
      name: "Intake Shell",
      progress_required: 9,
      trace_multiplier: 1.0,
      weakness: :spoof,
      reward: [{:scrip, 20}]
    },
    %{
      id: "template_lock",
      name: "Template Lock",
      progress_required: 12,
      trace_multiplier: 1.7,
      weakness: :decrypt,
      reward: [{:knowledge, "registry_seam_open"}]
    },
    %{
      id: "write_head",
      name: "Write-Head",
      progress_required: 15,
      trace_multiplier: 2.4,
      weakness: :backdoor,
      reward: [{:knowledge, "midgrid_echo"}]
    }
  ]
}
