# TODO: rework into the "accept" beat of a dispatch fetch task. on_complete should grant ONLY
# the outbound carried item {:inventory, "juno_pickup_chit", 1} and
# {:npc_progression, "shunt9_bazaar_juno", 1} — move the trust/favor/knowledge payout to the
# return beat (new shunt9_bazaar_juno_quiet_pickup_report POI at the Bazaar). The "run" step
# text should send the player to the Food Stalls contact to collect, rather than narrating it
# in place. (You carry the chit out, carry juno_pickup_goods back.)
%Shunt.Events.Event{
  id: "shunt9_bazaar_juno_quiet_pickup",
  title: "Quiet Pickup",

  on_complete: [
    {:modify_rep, "juno", :trust, 10},
    {:modify_rep, "juno", :favors, 1},
    {:knowledge, "juno_secret_supplier"},
    {:npc_progression, "shunt9_bazaar_juno", 1}
  ],

  steps: [
    %{
      id: "ask",
      text: """
      "Bigger one this time. A pickup I can't be seen near." Juno taps the table.
      "Do this clean and you're not just muscle to me anymore."
      """,
      choices: [
        %{label: "Where do I go?", next: "run"},
        %{label: "Too hot for me"}
      ]
    },
    %{
      id: "run",
      text: """
      The handoff goes smooth. On the way back Juno talks looser than usual, and
      lets slip where the goods really come from.
      """,
      choices: [
        %{label: "File that away", complete: true}
      ]
    }
  ]
}
