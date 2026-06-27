%Shunt.Events.Event{
  id: "liftworks_stamp_intro",
  title: "By the Book",

  on_complete: [
    {:npc_progression, "liftworks_intake_stamp", 1}
  ],

  steps: [
    %{
      id: "desk",
      text: """
      The clerk's badge says HOLLIS but the man two places back in line calls
      him Stamp, and Stamp answers to it. He doesn't hurry. "Transit clearance
      is a permit, a tariff, and a clean record. You have none of the three, so."
      He taps a form. "We start with the form."
      """,
      choices: [
        %{label: "What does it take?", next: "terms"},
        %{label: "Forget it"}
      ]
    },
    %{
      id: "terms",
      text: """
      "Permit's issued here, by me, once the tariff's paid. The tariff's the
      tariff — same for everyone, that's the point of it." He almost smiles.
      "People hate that it's fair. Come back with scrip and we'll make you
      legitimate."
      """,
      choices: [
        %{label: "I'll be back", complete: true}
      ]
    }
  ]
}
