%Shunt.Ghostwork.IceNode{
  id: "windlass_anchor_vault",
  name: "High Anchor Vault",
  family: "ice_authority",
  location_id: "windlass_high_anchor",

  # TODO: finalize per docs/SHUNT_STYLE_GUIDE.md — the Collective's white whale: the deck-forge the
  # Authority buried at the summit. This is the CAPSTONE (deck-as-vault-loot + the mastery long-tail).
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

  # TODO: author the 3-layer stack (the CAPSTONE — forces BOTH new keys, then loots the tier deck).
  #   L1 "gate": trace_multiplier 1.0, reward [{:scrip, 16}]
  #        subroutines: [%{id: "gate", key: :spoof, threat: :barrier, progress_required: 11}]
  #   L2 "wardens": trace_multiplier 1.75, reward [{:scrip, 16}]
  #        subroutines: [
  #          %{id: "warden_a", key: :cloak,    threat: :sentry, progress_required: 11},  # needs :cloak
  #          %{id: "warden_b", key: :overload, threat: :trap,   progress_required: 12}   # needs :overload (mismatch => @trap_trace_multiplier)
  #        ]
  #   L3 "forge_core": trace_multiplier 2.5, reward [{:knowledge, "windlass_deck_forge_taken"}, {:scrip, 24}]
  #        subroutines: [
  #          %{id: "core_lock", key: :backdoor, threat: :barrier, progress_required: 14},
  #          %{id: "forge_vault", key: :cloak, threat: :vault, progress_required: 16,
  #            # vault key :cloak is NOT core_lock's :backdoor, so any wrong hit here is a real lockout
  #            # gamble (like windlass_grid_core's :decrypt vault). reward is the deck + the overload upgrade:
  #            reward: [{:inventory, "fitworks_deck", 1}, {:inventory, "arc_driver", 1}, {:scrip, 40}]}
  #        ]
  #   DESIGN: L2 forces BOTH new keys on one board (cloak sentry + overload trap) — the loadout MUST
  #   carry them, which is exactly what the tier deck's 4th slot pays forward. The forge_vault drops
  #   fitworks_deck (vault-only) + arc_driver. Tune trace_multipliers so a clean full-drill genuinely
  #   burns Trace — this is the meanest ICE in the district. Numbers provisional.
  layers: []
}
