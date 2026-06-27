%Shunt.Events.Event{
  id: "shunt9_scrap_yard_grit_yard_trouble",
  title: "Grit",

  on_complete: [{:npc_progression, "shunt9_scrap_yard_grit", 1}],

  steps: [
    %{
      id: "trouble",
      text: """
      Grit's working half-speed, jaw tight. There's a stripped section
      near the east wall that didn't look that way yesterday.
      """,
      choices: [
        %{label: "Something wrong?", next: "wrong"},
        %{label: "Keep moving."}
      ]
    },
    %{
      id: "wrong",
      text: """
      "Crew's been coming in from the platform side before first light.
      Taking the good chassis before my people get to them. Third time
      this week." A look at you. "You hear anything about who's sending
      runners through the tunnel, I want to know."
      """,
      choices: [
        %{label: "I'll keep my ears open.", next: "keep"},
        %{label: "Not my problem.", next: "not_my_problem"}
      ]
    },
    %{
      id: "keep",
      text: """
      "That's worth something to me if it turns into a name." They go
      back to the rig. "Don't forget it."
      """,
      choices: [
        %{label: "You won't be forgotten either.", complete: true}
      ]
    },
    %{
      id: "not_my_problem",
      text: """
      "Everything in this yard's a problem eventually." Grit doesn't
      look up. "You'll figure that out."
      """,
      choices: [
        %{label: "Maybe.", complete: true}
      ]
    }
  ]
}
