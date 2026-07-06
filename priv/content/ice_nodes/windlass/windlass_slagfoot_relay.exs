%Shunt.Ghostwork.IceNode{
  id: "windlass_slagfoot_relay",
  name: "Slagfoot Reader Relay",
  family: "ice_authority",
  location_id: "windlass_slagworks",

  # TODO: finalize per docs/SHUNT_STYLE_GUIDE.md — an Authority relay welded shut at the core; the
  # first ICE your scavenged kit can't simply decrypt open. This is the :overload TEACHER.
  description:
    "An Authority reader-relay bolted into the foundry's oldest wall. Its face reads like any other node — but the trunk behind it is fused solid, the kind of lock that only opens for something with real current behind it.",

  requirements: [
    {:knows, "windlass_slagfoot_relay_found"}
  ],

  cool_threshold: 65,

  # TODO: author the 2-layer stack (the :overload TEACHER — introduces the new key without walling).
  #   L1 "handshake": trace_multiplier 1.0, reward [{:scrip, 12}]
  #        subroutines: [%{id: "handshake", key: :spoof, threat: :barrier, progress_required: 9}]
  #   L2 "power_trunk": trace_multiplier 1.5,
  #        reward [{:knowledge, "windlass_slagfoot_relay_cracked"}, {:scrip, 15}]
  #        subroutines: [
  #          %{id: "trunk_lock",  key: :overload, threat: :barrier, progress_required: 14}, # the :overload gate — a FAT barrier
  #          %{id: "trunk_watch", key: :decrypt,  threat: :sentry,  progress_required: 10}
  #        ]
  #   DESIGN: the :overload barrier is crackable WITHOUT an overload program (mismatched base
  #   programs use their `base` profile — slow, and Trace climbs while the sentry bleeds), so it
  #   TEACHES ("bring overload next time") rather than hard-walls. Tune trunk_lock.progress_required
  #   so the no-overload path is painful-but-survivable; with powerspike it's a clean smash. Numbers
  #   provisional — tune for feel once playable.
  layers: []
}
