%Shunt.Ghostwork.IceNode{
  id: "bloom_slate_ice",
  name: "The Slate's Book",
  family: "ice_security",
  location_id: "bloom_slate",
  description:
    "The betting market runs on a machine, and the machine keeps two books: the odds on the wall, and the ledger behind them. Scanning the Slate found the seam into the back office — the place the house decides who's worth wagering on. Crack it and you get what the odds are really priced off.",
  requirements: [
    {:knows, "bloom_slate_ice_found"}
  ],
  cool_threshold: 60,
  layers: [
    %{
      id: "floor_face",
      name: "The Floor Feed",
      trace_multiplier: 1.0,
      reward: [{:scrip, 12}],
      subroutines: [
        %{id: "floor_face_core", key: :spoof, threat: :barrier, progress_required: 8}
      ]
    },
    %{
      id: "back_book",
      name: "The Back Book",
      trace_multiplier: 2.0,
      # The ICE-locked rumor the finale RumorConnection requires — you can only get the ledger by
      # cracking the Slate, so a full crack of the case forces a Ghostwork run (playbook §5c).
      reward: [
        {:rumor, "bloom_ascension_ledger"},
        {:scrip, 18}
      ],
      subroutines: [
        %{id: "back_book_dec", key: :decrypt, threat: :sentry, progress_required: 12},
        %{id: "back_book_lock", key: :backdoor, threat: :trap, progress_required: 10}
      ]
    }
  ]
}
