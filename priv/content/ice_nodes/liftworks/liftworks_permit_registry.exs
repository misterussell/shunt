%Shunt.Ghostwork.IceNode{
  id: "liftworks_permit_registry",
  name: "Permit Registry",
  family: "ice_utility",
  location_id: "liftworks_watch_office",

  description:
    "The records terminal in the Watch Office, wired into the Latticework and older than the arch it serves. It holds every permit issued and every tag flagged. Reach the bottom of it and you can take your own name off the list the checkpoint keeps.",

  requirements: [
    {:knows, "permit_registry_found"}
  ],

  cool_threshold: 60,

  layers: [
    %{
      id: "terminal",
      name: "Open Terminal",
      trace_multiplier: 1.0,
      reward: [{:scrip, 12}],
      subroutines: [
        %{id: "terminal_core", key: :spoof, threat: :barrier, progress_required: 8}
      ]
    },
    %{
      id: "index",
      name: "Permit Index",
      trace_multiplier: 1.5,
      reward: [{:knowledge, "permit_registry_indexed"}, {:rumor, "scrubbed_watchlist"}],
      subroutines: [
        %{id: "index_core", key: :decrypt, threat: :barrier, progress_required: 10}
      ]
    },
    %{
      id: "watchlist",
      name: "Watchlist Record",
      trace_multiplier: 2.0,
      reward: [{:heat, -20}],
      subroutines: [
        %{id: "watchlist_core", key: :backdoor, threat: :barrier, progress_required: 12}
      ]
    }
  ]
}
