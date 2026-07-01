%Shunt.District.Def{
  id: "windlass",
  name: "The Windlass",
  facts: %{
    # The Latticework's control state — the Collective/Authority war's scoreboard. Clamped by
    # default (Authority lockdown). Any Authority node cracked or Collective relay flipped makes
    # it contested; cracking the grid core (the Collective's finale run) throws it fully open.
    # Derived only from Ghostwork knowledge + relay repairs, never stored — it cannot drift from
    # what the player has actually done.
    grid: %{
      kind: :ordinal,
      levels: [:clamped, :contested, :open],
      default: :clamped,
      rules: [
        {:open, [{:knows, "windlass_grid_open"}]},
        {:contested, [{:knows, "windlass_fitworks_ice_cracked"}]},
        {:contested, [{:infra_state, "windlass_fitworks_relay", "repaired"}]},
        {:contested, [{:infra_state, "windlass_market_relay", "repaired"}]}
      ]
    },
    # The great hauling engine at the base of the coil. Stalled until someone gets into the
    # superheated engine room and brings it back — patched runs it rough, repaired runs it clean;
    # either restores freight to Slagfoot. Derived from the windlass_engine repair alone.
    haul: %{
      kind: :ordinal,
      levels: [:stalled, :running],
      default: :stalled,
      rules: [
        {:running, [{:infra_state, "windlass_engine", "repaired"}]},
        {:running, [{:infra_state, "windlass_engine", "patched"}]}
      ]
    }
  }
}
