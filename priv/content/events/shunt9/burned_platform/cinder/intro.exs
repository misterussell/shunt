%Shunt.Events.Event{
  id: "shunt9_burned_platform_cinder_intro",
  title: "Cinder",

  on_complete: [{:npc_progression, "shunt9_burned_platform_cinder", 1}],

  steps: [
    %{
      id: "notice",
      text: """
      A figure sits on a slab of broken concrete near the melted door —
      not looking at it exactly, not looking away from it either. They've
      made a small camp here: a bedroll, a tin cup, a low-burning coil
      heater.
      """,
      choices: [
        %{label: "Approach them", next: "approach"},
        %{label: "Give them space"}
      ]
    },
    %{
      id: "approach",
      text: """
      They don't startle. They were already watching you.

      "You're new." Their voice is flat, careful. "Most people don't
      come this far down the platform unless they're lost or stupid.
      Which are you?"
      """,
      choices: [
        %{label: "Neither. Just looking around.", next: "looking"},
        %{label: "Lost, maybe.", next: "lost"}
      ]
    },
    %{
      id: "looking",
      text: """
      "Nothing to see here." A glance at the door behind them. "Not
      anymore." They turn back to the coil heater. "Name's Cinder.
      Come back if you find something worth talking about."
      """,
      choices: [
        %{label: "I will.", complete: true}
      ]
    },
    %{
      id: "lost",
      text: """
      Something softens, briefly. "Dead end either way." They gesture
      at the ruined space. "Name's Cinder. Platform's quieter than
      the bazaar. That's why I'm here." They don't explain further.
      """,
      choices: [
        %{label: "I can respect that.", complete: true}
      ]
    }
  ]
}
