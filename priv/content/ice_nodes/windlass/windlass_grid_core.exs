%Shunt.Ghostwork.IceNode{
  id: "windlass_grid_core",
  name: "The Grid Core",
  family: "ice_authority",
  location_id: "windlass_coldroom",

  description:
    "The trunk the whole Windlass grid hangs off — the single node every Authority reader in the district reports to. The Collective has wanted this for years and never had the hands to take it. Crack it and the district goes dark to the Authority all at once: the grid comes open, top to bottom. It is the deepest, meanest ICE you've faced, and it will cost you before it breaks.",

  requirements: [
    {:knows, "windlass_grid_core_found"}
  ],

  cool_threshold: 90,

  layers: [
    %{
      id: "trunk_face",
      name: "Trunk Face",
      trace_multiplier: 1.0,
      reward: [{:scrip, 18}],
      subroutines: [
        %{id: "trunk_face_core", key: :spoof, threat: :barrier, progress_required: 12}
      ]
    },
    %{
      id: "wardens",
      name: "Warden Ring",
      trace_multiplier: 1.5,
      reward: [{:scrip, 16}],
      subroutines: [
        %{id: "warden_a", key: :decrypt, threat: :sentry, progress_required: 12},
        %{id: "warden_b", key: :backdoor, threat: :sentry, progress_required: 12}
      ]
    },
    %{
      id: "core",
      name: "The Core",
      trace_multiplier: 3.0,
      reward: [
        {:knowledge, "windlass_grid_open"},
        {:scrip, 30},
        {:npc_loyalty, "windlass_drift", 6}
      ],
      # TODO (vault mechanic, v1 slice): add a THIRD subroutine to The Core with `threat: :vault`
      # — the Authority's master key to the whole district grid, the ultimate "go deeper for more"
      # prize on the meanest ICE in the game. Give it a key that differs from BOTH required subs'
      # keys (so any wrong hit is a genuine lockout gamble), a high progress_required, and a reward
      # bigger than the safe Core reward (extra scrip + a distinct knowledge key, e.g. a deeper
      # grid exploit, and/or more windlass_drift loyalty). With trace_multiplier already 3.0 here,
      # even a clean drill burns Trace hard — the classic "I have the key, but do I have the
      # headroom?" beat. Required core_trap/core_lock stay as-is and still bank the safe reward.
      subroutines: [
        %{id: "core_trap", key: :spoof, threat: :trap, progress_required: 11},
        %{id: "core_lock", key: :backdoor, threat: :barrier, progress_required: 15}
      ]
    }
  ]
}
