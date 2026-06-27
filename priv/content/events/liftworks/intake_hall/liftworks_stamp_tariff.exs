%Shunt.Events.Event{
  id: "liftworks_stamp_tariff",
  title: "The Tariff",

  on_complete: [
    {:scrip, -150},
    {:inventory, "transit_permit", 1},
    {:npc_progression, "liftworks_intake_stamp", 1}
  ],

  steps: [
    %{
      id: "pay",
      text: """
      Stamp counts the scrip without looking at you, which is its own kind of
      respect. "One transit permit. Good for the lifts, good until someone
      decides it isn't." He works the press — a real one, heavy, old — and the
      paper comes back warm with the Authority's mark pressed into it.
      """,
      choices: [
        %{label: "Take the permit", next: "done"},
        %{label: "Actually — keep the scrip"}
      ]
    },
    %{
      id: "done",
      text: """
      "Legitimate," Stamp says, like the word costs him nothing and you
      everything. "Lifts are through the Risers. Reader takes the permit. Don't
      lose it and don't lend it." He's already looking past you to the next in
      line.
      """,
      choices: [
        %{label: "Head for the lifts", complete: true}
      ]
    }
  ]
}
