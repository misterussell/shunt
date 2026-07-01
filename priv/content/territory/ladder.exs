%{
  id: "ladder",
  # The Territory ladder — human -> infrastructure (see priv/docs/SHUNT_territory_ladder_v1.md §2).
  # Tiers are ordered DEEPEST-FIRST: Shunt.Territory.tier/1 returns the first tier whose
  # requirements are all met, else the default {1, "Squatter"}. Each rung is gated by a keystone
  # module; the class floor for a keystone (e.g. the bleed needs class >= 2) is enforced when the
  # module is installed, so the ladder rule only needs the {:has_module, key} keystone.
  tiers: [
    # TODO: confirm "Junction" as the tier-6 name against the Content Constitution naming pass
    # (§9) before merge. Keystone is the Bleed Tap (the physical income module) installed in the
    # Bloom's class-3 duct-junction hideout; the Skim Crew is a second income module, not the rung
    # keystone.
    %{tier: 6, name: "Junction", requirements: [{:has_module, "bleed_tap"}]},
    %{tier: 5, name: "Node", requirements: [{:has_module, "signal_tap"}]},
    %{tier: 4, name: "Fixture", requirements: [{:has_module, "drop_point"}]},
    %{tier: 3, name: "Operator", requirements: [{:has_module, "latticework_bleed"}]},
    %{tier: 2, name: "Tenant", requirements: [{:has_module, "stash"}]}
    # Tier 1 "Squatter" is the default (no requirements) returned when no rung matches.
  ]
  # Deferred — tiers 7-10 (Relay, Hub, Spine, Grid) wire in with their keystone modules as those
  # districts land, after the Content Constitution pass on the names (§9). Tier 5 "Node" landed
  # with the Windlass (keystone: signal_tap in the Winder's Loft); tier 6 "Junction" lands with
  # the Bloom (keystone: bleed_tap in the Junction hideout).
}
