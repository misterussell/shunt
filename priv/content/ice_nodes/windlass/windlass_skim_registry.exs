%Shunt.Ghostwork.IceNode{
  id: "windlass_skim_registry",
  name: "Skim Watch Registry",
  family: "ice_authority",
  location_id: "windlass_the_skim",

  # TODO: finalize per docs/SHUNT_STYLE_GUIDE.md — the Authority's surveillance net over the market's
  # unread, thick with watchdogs. This is the :cloak SHOWCASE (a multi-sentry bleed race).
  description:
    "The Authority's quiet read on everyone the market won't officially see — the porters and sweepers of the Skim. It isn't fast ICE, but it's all eyes: a ring of watchdogs that bleed you worse the longer you stand in their light.",

  requirements: [
    {:knows, "windlass_skim_registry_found"}
  ],

  cool_threshold: 70,

  # TODO: author the 3-layer stack (the :cloak SHOWCASE — the "which watchdog do I kill first" race).
  #   L1 "face": trace_multiplier 1.0, reward [{:scrip, 12}]
  #        subroutines: [%{id: "face", key: :decrypt, threat: :barrier, progress_required: 10}]
  #   L2 "watch_ring": trace_multiplier 1.5,
  #        reward [{:inventory, "nullsleeve", 1}, {:scrip, 14}]   # LOOT: the :cloak upgrade (crack->loot)
  #        subroutines: [
  #          %{id: "watch_a", key: :cloak, threat: :sentry, progress_required: 9},
  #          %{id: "watch_b", key: :cloak, threat: :sentry, progress_required: 9},
  #          %{id: "watch_c", key: :cloak, threat: :sentry, progress_required: 9}  # 3 live sentries => @sentry_bleed stacks x3/turn
  #        ]
  #   L3 "store": trace_multiplier 2.0,
  #        reward [{:knowledge, "windlass_skim_registry_cracked"}, {:scrip, 20}]
  #        subroutines: [%{id: "store", key: :backdoor, threat: :barrier, progress_required: 12}]
  #   DESIGN: without :cloak you fight 3 sentries with mismatched base programs while the bleed stacks
  #   x3/turn — a genuine Trace-bust threat. With dampener/nullsleeve (near-zero Trace) you take them
  #   down quiet, one at a time, and the bleed drains as each dies. Tune @sentry_bleed exposure vs
  #   progress_required so the no-cloak path really threatens to bust. Numbers provisional.
  layers: []
}
