%Shunt.Events.Event{
  id: "shunt9_bazaar_juno_move_package",
  title: "Move a Package",

  on_complete: [
    {:scrip, 50},
    {:modify_rep, "juno", :trust, 10},
    {:npc_progression, "shunt9_bazaar_juno", 1}
  ],

  steps: [
    %{
      id: "offer",
      text: """
      Juno slides a flat, wrapped parcel across the table without quite looking
      at you. "Across the platform. No questions, no scans. Half now, half when
      it lands."
      """,
      choices: [
        %{label: "Take the job", next: "deliver"},
        %{label: "Not today"}
      ]
    },
    %{
      id: "deliver",
      text: """
      You hand it off under the dead lamps past the food stalls. Whatever was
      inside, nobody came looking. Juno notices that.
      """,
      choices: [
        %{label: "Collect the rest", complete: true}
      ]
    }
  ]
}
