%Shunt.Events.Event{
  id: "crossgate_west_platform_fight_board",
  title: "Fight Board",

  on_complete: [{:knowledge, "crossgate_the_drop_location"}],

  steps: [
    %{
      id: "inspect",
      text: """
      A battered corkboard next to the bar lists the week's scheduled
      fights — names, weights, handicaps, and odds written in chalk that
      gets updated between rounds. A separate column lists which vendors
      are cleared to operate on fight nights.
      """,
      choices: [
        %{label: "Read the vendor list", next: "vendors"},
        %{label: "Check the fight schedule", next: "fights"}
      ]
    },
    %{
      id: "vendors",
      text: """
      Food, drink, betting slips, a medical station that operates with
      no questions. Near the bottom of the list, in smaller writing than
      the rest: "Hardware — see door marked with the red scratch, west
      service corridor."

      The kind of hardware that doesn't get named on a board.
      """,
      choices: [
        %{label: "File that away.", complete: true}
      ]
    },
    %{
      id: "fights",
      text: """
      Three bouts this week. The odds are posted in a shorthand you
      don't fully read yet — but you recognize that two of the fighters
      are listed under the Syndicate's mark. The third is independent,
      which probably means they won't stay that way for long.
      """,
      choices: [
        %{label: "Keep moving."}
      ]
    }
  ]
}
