%Shunt.Ghostwork.IceNode{
  id: "crossgate_counting_house_ledger",
  name: "Syndicate Ledger",
  family: "ice_security",
  location_id: "crossgate_counting_house",

  description:
    "The Syndicate's financial records for The Crossgate, protected by the most current security ICE in the building. Cracking it is a significant risk — this is their own house. The rewards reflect what's at stake.",

  requirements: [
    {:knows, "crossgate_counting_house_ledger_found"}
  ],

  cool_threshold: 75,

  layers: [
    %{
      id: "outer_lock",
      name: "Outer Lock",
      trace_multiplier: 1.0,
      reward: [{:scrip, 20}],
      subroutines: [
        %{id: "outer_lock_core", key: :spoof, threat: :barrier, progress_required: 10}
      ]
    },
    %{
      id: "ledger_access",
      name: "Ledger Access",
      trace_multiplier: 1.5,
      reward: [{:knowledge, "crossgate_syndicate_cut_structure"}],
      subroutines: [
        %{id: "ledger_access_core", key: :decrypt, threat: :barrier, progress_required: 13}
      ]
    },
    %{
      id: "debt_registry",
      name: "Debt Registry",
      trace_multiplier: 2.25,
      reward: [{:knowledge, "crossgate_syndicate_debt_registry"}],
      # TODO (vault mechanic, v1 slice): add a SECOND subroutine to this deepest layer with
      # `threat: :vault` — the Syndicate's off-book skim, the "rich payload" that tempts a greedy
      # run on their own house. Give it its own key (e.g. :spoof, deliberately DIFFERENT from the
      # layer's required :backdoor so a wrong-program mis-hit is a real lockout risk), a
      # progress_required comparable to the core, and a fat reward (scrip + a knowledge key worth
      # more than the safe debt_registry reward). Since only a master reads the vault's key,
      # looting it should feel like the payoff of having ground this family. Leave the required
      # debt_registry_core as-is; the safe reward still banks without touching the vault.
      subroutines: [
        %{id: "debt_registry_core", key: :backdoor, threat: :barrier, progress_required: 16}
      ]
    }
  ]
}
