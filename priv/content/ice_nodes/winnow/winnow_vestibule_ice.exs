%Shunt.Ghostwork.IceNode{
  id: "winnow_vestibule_ice",
  name: "The Channel Above",
  family: "ice_authority",
  location_id: "winnow_vestibule",
  description:
    "The channel in the Vestibule wall is the deepest ICE the Authority keeps in its first district, and it isn't the Authority's — it's the thing the Authority answers to, reaching down through it. Crack it and you walk the quota back up past the wardens toward whatever writes it. The shunt in your skull, the one the Bloom's Gloss started, will try to finish while you're in here. You'll be reading the channel and it will be reading you.",
  requirements: [
    {:knows, "winnow_tier_above"}
  ],
  cool_threshold: 95,
  layers: [
    %{
      id: "seal_face",
      name: "The Seal",
      trace_multiplier: 1.2,
      reward: [{:scrip, 20}],
      subroutines: [
        %{id: "seal_core", key: :backdoor, threat: :barrier, progress_required: 13}
      ]
    },
    %{
      id: "the_reach",
      name: "The Reach",
      trace_multiplier: 2.0,
      reward: [{:scrip, 22}],
      subroutines: [
        %{id: "reach_a", key: :decrypt, threat: :sentry, progress_required: 14},
        %{id: "reach_b", key: :spoof, threat: :trap, progress_required: 13}
      ]
    },
    %{
      id: "the_shunt_completes",
      name: "The Shunt Completes",
      trace_multiplier: 3.2,
      # Finale: the Gloss interface from the Bloom finishes itself here (SHUNT_STORY_CANON.md hook #4),
      # and the player walks the channel far enough to confirm the tier above the Authority. Grants
      # winnow_shunt_complete, which opens the way up to the Head-End and the district's payoff beat.
      reward: [
        {:knowledge, "winnow_shunt_complete"},
        {:scrip, 40}
      ],
      subroutines: [
        %{id: "shunt_trap", key: :spoof, threat: :trap, progress_required: 14},
        %{id: "shunt_lock", key: :backdoor, threat: :barrier, progress_required: 17}
      ]
    }
  ]
}
