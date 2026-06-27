%Shunt.Events.Event{
  id: "crossgate_commissary_hest_supply_problem",
  title: "Hest",

  on_complete: [{:npc_progression, "crossgate_commissary_hest", 1}],

  steps: [
    %{
      id: "short",
      text: """
      The relay component shelf is empty — not just picked over,
      cleaned out. Hest is behind the counter doing math on paper,
      looking like the math isn't working.
      """,
      choices: [
        %{label: "What happened to the relay stock?", next: "stock"},
        %{label: "Come back later."}
      ]
    },
    %{
      id: "stock",
      text: """
      "My supplier from the upper Midgrid stopped moving. No
      notice, no reason given." They put the paper down. "Someone
      put pressure on the route — either KA or a corp, doesn't
      matter which. The effect is the same." A look at you.
      "You know anyone moving relay components out of Shunt 9?
      I'll pay above market to rebuild the shelf."
      """,
      choices: [
        %{label: "I can look into it.", next: "look"},
        %{label: "Not my supply chain.", next: "not_mine"}
      ]
    },
    %{
      id: "look",
      text: """
      "That's all I need." Hest writes a number on a scrap of
      paper. "That's what I'll pay per unit, above whatever the
      yard rate is. Don't make me wait too long — people need
      these things."
      """,
      choices: [
        %{label: "I'll see what I can find.", complete: true}
      ]
    },
    %{
      id: "not_mine",
      text: """
      "Fair." They pick the paper back up. "If that changes,
      the offer stands."
      """,
      choices: [
        %{label: "Understood.", complete: true}
      ]
    }
  ]
}
