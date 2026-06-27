%Shunt.Events.Event{
  id: "shunt9_bazaar_wrench_banter",
  title: "Wrench's Bench",
  repeatable: true,

  on_complete: [
    {:npc_loyalty, "shunt9_bazaar_wrench", 1}
  ],

  steps: [
    %{
      id: "talk",
      text: """
      Wrench is elbow-deep in a servo housing, talking more to the part than to
      you. "People think salvage is luck. It's not. It's knowing what breaks
      first and getting there before the next picker." A glance up. "You scavenge
      yet? You should. Half this row is built out of what other people threw away.
      Bring me the coils and boards, I'll show you what they turn into."
      """,
      choices: [
        %{label: "I'll keep an eye out", complete: true}
      ]
    }
  ]
}
