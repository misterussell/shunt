# TODO: rework into the "accept" beat of a round-trip dispatch task. on_complete should grant
# ONLY the carried item {:inventory, "juno_parcel", 1} and
# {:npc_progression, "shunt9_bazaar_juno", 1} — move the 50 scrip + trust 10 payout to the
# return beat (new shunt9_bazaar_juno_move_package_report POI at the Bazaar). The "deliver" step
# text should stop narrating the handoff in place and instead point the player to the Food
# Stalls contact (the new recipient NPC).
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
