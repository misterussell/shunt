%Shunt.Events.Event{
  id: "windlass_drift_loft",
  title: "A Fixture, Not a Stray",
  repeatable: false,

  requirements: [
    {:knows, "windlass_collective_vouched"}
  ],

  on_complete: [
    {:knowledge, "windlass_loft_offered"}
  ],

  steps: [
    %{
      id: "offer",
      text: """
      "There's a fitting loft over the benches, been empty since the last tenant got
      read wrong," Drift says. "We cleared it off every manifest in the district.
      As far as the grid's concerned, it isn't there — which means neither are you,
      when you're in it." She almost smiles. "It's wired straight into the trunk. A
      Signal Tap in that floor would skim the district grid for you, and the more of
      the grid we crack open, the more it'd pay."
      """,
      choices: [
        %{label: "What's the catch?", next: "terms"}
      ]
    },
    %{
      id: "terms",
      text: """
      "The catch is it costs, and the catch is it makes you ours — properly, not just
      vouched. The Collective doesn't house strays." She holds your eye. "Take it
      when you can pay it. Move your bench in, tap the trunk, and you stop being
      someone passing through the Windlass and start being a fixture in it. First
      real address the grid ever gave you. Go on. It'll keep till you're ready."
      """,
      choices: [
        %{label: "I'll take it when I can", complete: true}
      ]
    }
  ]
}
