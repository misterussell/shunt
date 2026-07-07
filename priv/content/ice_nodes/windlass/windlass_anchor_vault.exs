%Shunt.Ghostwork.IceNode{
  id: "windlass_anchor_vault",
  name: "The Anchor Forge",
  family: "ice_authority",
  location_id: "windlass_high_anchor",

  description:
    "Under the clean lamps of High Anchor, behind the deepest ICE in the Windlass, the Authority keeps the one thing the Collective has never been able to build for itself: a deck-forge. Reading it takes more than tools — it takes knowing Authority ICE the way its own wardens do.",

  # Gated on DEEP Authority mastery — you must have cracked the family >= 6 times (well past KEYS=3),
  # so by the time this surfaces the vault's key is un-redacted and you can drill it deliberately
  # instead of gambling. This is the mastery long-tail payoff (reuses the existing requirement; no
  # new engine surface). The revealing lattice lead (windlass_high_anchor.exs) carries the same gate.
  requirements: [
    {:knows, "windlass_anchor_vault_found"},
    {:ghostwork_mastery_at_least, "ice_authority", 6}
  ],

  cool_threshold: 85,

  # The CAPSTONE. L2 forces BOTH new keys on one board (a :cloak sentry + an :overload trap), so the
  # loadout MUST carry them — exactly what the tier deck's 4th slot pays forward. The forge_vault
  # (keyed :cloak, NOT core_lock's :backdoor — so any wrong hit is a real lockout gamble, like
  # windlass_grid_core's :decrypt vault) drops the tier deck (vault-only) + the :overload upgrade.
  # TODO: tune trace_multipliers / progress_required for feel once the district is playable — a clean
  # full-drill should genuinely burn Trace (this is the meanest ICE in the Windlass).
  layers: [
    %{
      id: "gate",
      name: "Anchor Face",
      trace_multiplier: 1.0,
      reward: [{:scrip, 16}],
      subroutines: [
        %{id: "gate", key: :spoof, threat: :barrier, progress_required: 11}
      ]
    },
    %{
      id: "wardens",
      name: "Warden Pair",
      trace_multiplier: 1.75,
      reward: [{:scrip, 16}],
      subroutines: [
        %{id: "warden_a", key: :cloak, threat: :sentry, progress_required: 11},
        %{id: "warden_b", key: :overload, threat: :trap, progress_required: 12}
      ]
    },
    %{
      id: "forge_core",
      name: "The Forge Core",
      trace_multiplier: 2.5,
      reward: [{:knowledge, "windlass_deck_forge_taken"}, {:scrip, 24}],
      subroutines: [
        %{id: "core_lock", key: :backdoor, threat: :barrier, progress_required: 14},
        %{
          id: "forge_vault",
          key: :cloak,
          threat: :vault,
          progress_required: 16,
          reward: [{:inventory, "fitworks_deck", 1}, {:inventory, "arc_driver", 1}, {:scrip, 40}]
        }
      ]
    }
  ]
}
