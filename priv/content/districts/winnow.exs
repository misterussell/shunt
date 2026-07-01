%Shunt.District.Def{
  id: "winnow",
  name: "The Winnow",
  facts: %{
    # The Authority's demand on the Floor — pushed DOWN from above the wardens, fed from BELOW by
    # the Bloom's throat. When the number can't be made from intake, the wardens make it from the
    # servant caste: they cull their own into the wire. Derived only from knowledge + the sorting
    # line's repair state, never stored.
    #
    # Entry-state divergence (the Bloom's ending drives the opening state):
    #   - Expose (bloom_throat_starved): the supply from below is dead, so the Floor eats its own
    #     to make quota — forced to :culling at the TOP of the rule list, regardless of any repair.
    #   - Ascend (bloom_ascended): the throat ran and fed the Floor, so supply is fine but the
    #     pressure from above never lets up — the default :pressing.
    # The player can ease it (smuggle intake / forge the tally -> winnow_quota_bought, or clear the
    # backlogged sorting line) or weaponize it (jam the line -> winnow_line_jammed forces a reckoning).
    quota: %{
      kind: :ordinal,
      levels: [:easing, :pressing, :culling],
      default: :pressing,
      rules: [
        # Supply starved from below (Expose) — nothing to sort, so they cull. Beats any line repair.
        {:culling, [{:knows, "bloom_throat_starved"}]},
        # Player jams the sorting line to force the reckoning into the open.
        {:culling, [{:knows, "winnow_line_jammed"}]},
        # The backlogged line cleared and running — the Floor keeps up, nobody gets culled for numbers.
        {:easing, [{:infra_state, "winnow_sorting_line", "repaired"}]},
        # Numbers padded off the book — smuggled intake, a forged tally.
        {:easing, [{:knows, "winnow_quota_bought"}]},
        # A rough patch on the line takes some of the pressure off, but not enough to ease it.
        {:pressing, [{:infra_state, "winnow_sorting_line", "patched"}]}
      ]
    },
    # How awake the servant caste is to what they are — kept-whole ascended who think they made it,
    # and are one bad quota from the wire. Player-fed: reaching the half-culled (Tithe) stirs them;
    # the foreman's turn once she's seen the truth makes them lucid. Scales the Line Tap income.
    waking: %{
      kind: :ordinal,
      levels: [:dulled, :stirring, :lucid],
      default: :dulled,
      rules: [
        {:lucid, [{:knows, "winnow_caste_lucid"}]},
        {:stirring, [{:knows, "winnow_caste_stirring"}]}
      ]
    }
  }
}
