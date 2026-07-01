%Shunt.Repair.Repairable{
  id: "winnow_sorting_line",
  name: "The Backlogged Sorting Line",
  location_id: "winnow_sorting_floor",
  initial_state: "broken",

  # The conveyor spine of the winnow. Its drive is failing and half its readers are dead, so the
  # line runs behind — arrivals stack up faster than the caste can sort them, and when the count
  # falls behind the number, the wardens make up the difference by culling the caste itself. Clear
  # the backlog and reseat the drive and the line keeps pace, so nobody gets culled to hit quota:
  # the district `quota` fact eases off a full repair, takes some relief off a rough patch. (A
  # STARVED supply from below — the Expose ending — overrides this: no load to sort means the line
  # can't help, so quota stays at :culling regardless. And a player can deliberately JAM the line via
  # Roan to force a reckoning: winnow_line_jammed also holds quota at :culling.)
  inspect_tiers: [
    %{
      requirements: [],
      text:
        "The line runs, but it runs sick — the drive shuddering, whole banks of readers dark, arrivals piling at the head faster than the belt clears them. Every stall is a cull downstream, and the caste knows it, and works the jam with their hands to keep the count from falling behind."
    },
    %{
      requirements: [{:has_item, "scrap_forged_soldering_iron"}],
      text:
        "You get into the drive housing. It's not just wear — the pace-governor's been throttled deliberately, the same clean throttle you've seen on Authority gear, the line kept just slow enough that the count runs short and the caste keeps paying the shortfall."
    },
    %{
      requirements: [{:has_item, "diagnostic_probe"}],
      text:
        "The probe reads it through: reseat the drive relay, clear the throttle, and wake the dead reader banks, and the line keeps pace with the Maw on its own. Do it rough and it'll clear the worst of the backlog; do it right and the count never falls behind the number again — and the culls stop."
    }
  ],
  solutions: [
    %{
      id: "improvised",
      label: "Clear the Jam Rough",
      from: ["broken"],
      requirements: [{:has_item, "scrap_forged_soldering_iron"}],
      consumes: %{"improvised_relay" => 1},
      result_state: "patched",
      effects: [],
      outcome_text:
        "You wind the drive a relay by hand and knock the worst of the readers back awake. The belt picks up — not clean, but clearing, the head-of-line stack coming down. It won't keep pace at a hard quota, but on an ordinary shift the caste stops falling behind, and downstream the Cull Line runs a little lighter."
    },
    %{
      id: "standard",
      label: "Reseat the Drive",
      from: ["broken", "patched"],
      requirements: [{:has_item, "scrap_forged_soldering_iron"}],
      consumes: %{"standard_relay" => 1},
      result_state: "repaired",
      effects: [],
      outcome_text:
        "You clear the throttle, seat a clean relay in the drive, and bring every reader bank up. The line runs even and keeps pace with the Maw for the first time in memory. The count tracks the number without anyone leaning on the caste to close the gap — and the Cull Line goes quiet of everything but the genuinely spoiled. It's the most good a wrench ever did up here."
    }
  ],
  state_descriptions: %{
    "patched" =>
      "The sorting line running rough but clearing — the drive hand-wound, the backlog coming down, the caste no longer sorting against a stack that beats them. On an easy shift, nobody gets culled for the count. On a hard one, it still won't hold.",
    "repaired" =>
      "The sorting line running even and awake, keeping exact pace with the Maw. The count tracks the number honestly, the caste sorts without dread, and the Cull Line carries only what's truly spoiled. The one honest machine in the Winnow, and it took a spoiled thing like you to fix it."
  }
}
