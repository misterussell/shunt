%Shunt.Events.Event{
  id: "shunt9_player_squat_knowledge_chits",
  title: "Stolen Kaspav Authority Knowledge-Chits",

  steps: [
    %{
      id: "inspect",
      text: """
      Several stolen Kaspav Authority knowledge-chits sit in a hidden compartment of your squat, each one humming faintly with restricted data.
      These contain fragments of restricted information, valuable on the web, but also potentially dangerous if the Authority discovers you have them. Use them wisely and you'll be able to build leverage or call in favors from the Web.
      """,
      choices: [
        %{label: "Read a chit", next: "fragments"},
        %{label: "Keep them hidden", complete: true}
      ]
    },
    %{
      id: "fragments",
      text: """
      Fragments of Kaspav Authority network traffic scroll past — routing tables,
      patrol schedules, names you don't recognize yet.
      With a burner ledger and some well timed leaks you could use this information to your advantage, but be careful. The Authority is always watching.
      """,
      rewards: [
        {:knowledge, :authority_networks}
      ],
      complete: true
    }
  ]
}
