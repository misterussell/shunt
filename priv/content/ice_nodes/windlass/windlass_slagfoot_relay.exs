%Shunt.Ghostwork.IceNode{
  id: "windlass_slagfoot_relay",
  name: "Slagfoot Reader Relay",
  family: "ice_authority",
  location_id: "windlass_slagworks",

  description:
    "An Authority reader-relay bolted into the foundry's oldest wall. Its face reads like any other node — but the trunk behind it is fused solid, the kind of lock that only opens for something with real current behind it.",

  requirements: [
    {:knows, "windlass_slagfoot_relay_found"}
  ],

  cool_threshold: 65,

  # The :overload TEACHER. trunk_lock is a FAT :overload :barrier — crackable without an overload
  # program (mismatched base programs use their `base` profile: slow, and Trace climbs while the
  # sentry bleeds), so it teaches "bring overload next time" rather than hard-walling. With powerspike
  # it's a clean smash.
  # TODO: tune trunk_lock.progress_required for feel — the no-overload path should be painful but
  # survivable once the district is playable.
  layers: [
    %{
      id: "handshake",
      name: "Reader Handshake",
      trace_multiplier: 1.0,
      reward: [{:scrip, 12}],
      subroutines: [
        %{id: "handshake", key: :spoof, threat: :barrier, progress_required: 9}
      ]
    },
    %{
      id: "power_trunk",
      name: "Power Trunk",
      trace_multiplier: 1.5,
      reward: [{:knowledge, "windlass_slagfoot_relay_cracked"}, {:scrip, 15}],
      subroutines: [
        %{id: "trunk_lock", key: :overload, threat: :barrier, progress_required: 14},
        %{id: "trunk_watch", key: :decrypt, threat: :sentry, progress_required: 10}
      ]
    }
  ]
}
