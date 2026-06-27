%Shunt.Events.Event{
  id: "crossgate_commissary_hest_intro",
  title: "Hest",

  on_complete: [{:npc_progression, "crossgate_commissary_hest", 1}],

  steps: [
    %{
      id: "counter",
      text: """
      The proprietor is restocking a shelf behind the counter —
      methodical, unhurried, not visibly interested in you. When
      they turn around, they take in what you're wearing and what
      you're not carrying and price you accordingly.

      "First time in. You came from Shunt 9 — the tunnel." Not
      a question. "We're better stocked than whatever you've been
      buying there. Price list is on the board. Name's Hest."
      """,
      choices: [
        %{label: "What do you carry?", next: "stock"},
        %{label: "Just looking.", next: "looking"}
      ]
    },
    %{
      id: "stock",
      text: """
      "What you see. Components, consumables, tools, some raws
      I source direct. No weapons, no augment material — that's
      the arrangement with the Syndicate." A gesture at the
      shelves. "If I don't have it, I can sometimes get it.
      Takes time and it costs more."
      """,
      choices: [
        %{label: "Good to know.", complete: true}
      ]
    },
    %{
      id: "looking",
      text: """
      "Take your time." Hest goes back to the shelf. "The price
      list is accurate. I don't negotiate on first visits."
      """,
      choices: [
        %{label: "Fair enough.", complete: true}
      ]
    }
  ]
}
