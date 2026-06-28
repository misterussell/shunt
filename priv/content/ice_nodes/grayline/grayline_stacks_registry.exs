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
      trace_multiplier: 1.0,
      reward: [{:scrip, 20}],
      subroutines: [
        %{id: "intake_shell_core", key: :spoof, threat: :barrier, progress_required: 9}
      ]
    },
    %{
      id: "template_lock",
      name: "Template Lock",
      trace_multiplier: 1.7,
      reward: [{:knowledge, "registry_seam_open"}],
      subroutines: [
        %{id: "template_lock_core", key: :decrypt, threat: :barrier, progress_required: 12}
      ]
    },
    %{
      id: "write_head",
      name: "Write-Head",
      trace_multiplier: 2.4,
      reward: [{:knowledge, "midgrid_echo"}],
      subroutines: [
        # Feed it a Court-shaped template stub (spoof), keep the watch process from
        # climbing while you work (decrypt sentry), and ease the write-head over without
        # forcing it — trip the flag with the wrong key and the write lands flagged.
        %{id: "template_stub", key: :spoof, threat: :barrier, progress_required: 8},
        %{id: "court_watch", key: :decrypt, threat: :sentry, progress_required: 7},
        %{id: "flag_head", key: :backdoor, threat: :trap, progress_required: 6}
      ]
    }
  ]
}
