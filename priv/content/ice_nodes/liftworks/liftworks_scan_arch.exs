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
      progress_required: 8,
      trace_multiplier: 1.0,
      weakness: :spoof,
      reward: [{:scrip, 15}]
    },
    %{
      id: "arbiter",
      name: "Clearance Arbiter",
      progress_required: 11,
      trace_multiplier: 1.6,
      weakness: :decrypt,
      reward: [{:knowledge, "scan_arch_logic_mapped"}]
    },
    %{
      id: "tag_writer",
      name: "Tag Writer",
      progress_required: 14,
      trace_multiplier: 2.2,
      weakness: :backdoor,
      reward: [{:knowledge, "scan_arch_spoofed"}]
    }
  ]
}
