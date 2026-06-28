%Shunt.Ghostwork.IceNode{
  id: "liftworks_scan_arch",
  name: "Scan Arch",
  family: "ice_security",
  location_id: "liftworks_intake_hall",

  description:
    "The checkpoint's reader, current-spec on the front and decades-old on the back where Splice says nobody patched it. It decides who goes up. Crack it clean and it will write you a tag the lift believes; trip it and you join the line of the turned-back.",

  requirements: [
    {:knows, "scan_arch_found"}
  ],

  cool_threshold: 75,

  layers: [
    %{
      id: "housing",
      name: "Housing Port",
      trace_multiplier: 1.0,
      reward: [{:scrip, 15}],
      subroutines: [
        %{id: "housing_core", key: :spoof, threat: :barrier, progress_required: 8}
      ]
    },
    %{
      id: "arbiter",
      name: "Clearance Arbiter",
      trace_multiplier: 1.6,
      reward: [{:knowledge, "scan_arch_logic_mapped"}],
      subroutines: [
        %{id: "arbiter_core", key: :decrypt, threat: :barrier, progress_required: 11}
      ]
    },
    %{
      id: "tag_writer",
      name: "Tag Writer",
      trace_multiplier: 2.2,
      reward: [{:knowledge, "scan_arch_spoofed"}],
      subroutines: [
        %{id: "tag_writer_core", key: :backdoor, threat: :barrier, progress_required: 14}
      ]
    }
  ]
}
