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
      progress_required: 8,
      trace_multiplier: 1.0,
      weakness: :spoof,
      reward: [{:scrip, 12}]
    },
    %{
      id: "index",
      name: "Permit Index",
      progress_required: 10,
      trace_multiplier: 1.5,
      weakness: :decrypt,
      reward: [{:knowledge, "permit_registry_indexed"}, {:rumor, "scrubbed_watchlist"}]
    },
    %{
      id: "watchlist",
      name: "Watchlist Record",
      progress_required: 12,
      trace_multiplier: 2.0,
      weakness: :backdoor,
      reward: [{:heat, -20}]
    }
  ]
}
