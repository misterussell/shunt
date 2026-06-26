%Shunt.Events.Event{
  id: "shunt9_bazaar_juno_move_package",
  title: "Move a Package",

  on_complete: [
    {:inventory, "juno_parcel", 1},
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
      Juno presses the parcel into your hands. "Food stalls — there's someone
      working the wok on the far end. They'll know what it is."
      """,
      choices: [
        %{label: "Head over", complete: true}
      ]
    }
  ]
}
