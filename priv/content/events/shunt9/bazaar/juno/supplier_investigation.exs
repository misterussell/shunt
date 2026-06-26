# TODO: rework into the field-investigation leg of a persistent-gate task. Move this POI from
# the Bazaar to the shunt9_supplier_drop location's events: list (remove it from the Bazaar's
# events:). Keep requirements [{:knows, "juno_secret_supplier"}] — that existing gate covers
# the outbound leg, so no carried-item is needed to reach it. Change on_complete to grant
# {:inventory, "juno_supplier_dossier", 1} INSTEAD of paying out; the 150 scrip + trust 10 move
# to the new shunt9_bazaar_juno_supplier_investigation_report POI at the Bazaar.
%Shunt.Events.Event{
  id: "shunt9_bazaar_juno_supplier_investigation",
  title: "Supplier Investigation",

  requirements: [
    {:knows, "juno_secret_supplier"}
  ],

  on_complete: [
    {:scrip, 150},
    {:modify_rep, "juno", :trust, 10}
  ],

  steps: [
    %{
      id: "dig",
      text: """
      Now that you know where Juno's stock comes from, the supply line is worth a
      closer look. A quiet afternoon of asking the right people the wrong
      questions turns up a name worth selling back to her.
      """,
      choices: [
        %{label: "Bring it to Juno", complete: true},
        %{label: "Sit on it"}
      ]
    }
  ]
}
