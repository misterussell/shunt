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

  # The :cloak SHOWCASE — a "which watchdog do I kill first" race. watch_ring runs three live :cloak
  # sentries at once, so @sentry_bleed stacks x3/turn: without :cloak you fight them with mismatched
  # base programs while the bleed climbs (a genuine Trace-bust threat); with dampener/nullsleeve
  # (near-zero Trace) you take them down quiet, one at a time, and the bleed drains as each dies.
  # It loots nullsleeve (the :cloak upgrade) — crack->loot.
  # TODO: tune @sentry_bleed exposure vs progress_required for feel so the no-cloak path really
  # threatens to bust.
  layers: [
    %{
      id: "face",
      name: "Registry Face",
      trace_multiplier: 1.0,
      reward: [{:scrip, 12}],
      subroutines: [
        %{id: "face", key: :decrypt, threat: :barrier, progress_required: 10}
      ]
    },
    %{
      id: "watch_ring",
      name: "Watch Ring",
      trace_multiplier: 1.5,
      reward: [{:inventory, "nullsleeve", 1}, {:scrip, 14}],
      subroutines: [
        %{id: "watch_a", key: :cloak, threat: :sentry, progress_required: 9},
        %{id: "watch_b", key: :cloak, threat: :sentry, progress_required: 9},
        %{id: "watch_c", key: :cloak, threat: :sentry, progress_required: 9}
      ]
    },
    %{
      id: "store",
      name: "Correlation Store",
      trace_multiplier: 2.0,
      reward: [{:knowledge, "windlass_skim_registry_cracked"}, {:scrip, 20}],
      subroutines: [
        %{id: "store", key: :backdoor, threat: :barrier, progress_required: 12}
      ]
    }
  ]
}
