%Shunt.Events.Event{
  id: "shunt9_player_squat_knowledge_chits",
  title: "Stolen Kaspav Authority Knowledge-Chits",

  steps: [
    %{
      id: "inspect",
      text: """
      Several stolen Authority knowledge-chits sit in a hidden pocket of your
      jacket, each one humming faintly with restricted data.
      """,
      choices: [
        %{label: "Read a chit", next: "fragments"},
        %{label: "Keep them hidden", complete: true}
      ]
    },
    %{
      id: "fragments",
      text: """
      Fragments of Authority network traffic scroll past — routing tables,
      patrol schedules, names you don't recognize yet.
      """,
      rewards: [
        {:knowledge, :authority_networks}
      ],
      complete: true
    }
  ]
}
