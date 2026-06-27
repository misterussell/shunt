%Shunt.Events.Event{
  id: "supplier_conspiracy_failure",
  title: "Wrong Read",
  repeatable: true,

  on_complete: [
    {:heat, 15}
  ],

  steps: [
    %{
      id: "burn",
      text: """
      The theory doesn't hold. You pointed at the wrong operation, and somewhere
      in the process you asked the wrong question to the wrong person.

      Word travels fast in Shunt 9. Someone who should have stayed ignorant now
      knows you're looking.
      """,
      choices: [
        %{label: "Go quiet", complete: true}
      ]
    }
  ]
}
