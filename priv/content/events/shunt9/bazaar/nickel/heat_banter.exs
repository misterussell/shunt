%Shunt.Events.Event{
  id: "shunt9_bazaar_nickel_heat_banter",
  title: "Nickel's Read",
  repeatable: true,

  on_complete: [],

  steps: [
    %{
      id: "read",
      text: """
      Nickel reads you the way he reads everyone — eyes first to your hands, then
      your pockets, then the door. "You're warm today, or you're cold. I can
      usually tell." Whatever he decides, he keeps to himself. "Word of advice
      I don't charge for: don't let the tab run. Heat's quiet right up until it
      isn't, and then it's the whole platform looking your way at once. Spend it
      down before somebody spends it for you."
      """,
      choices: [
        %{label: "I'll keep it cold", complete: true}
      ]
    }
  ]
}
