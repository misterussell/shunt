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
