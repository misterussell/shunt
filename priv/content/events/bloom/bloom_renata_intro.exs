%Shunt.Events.Event{
  id: "bloom_renata_intro",
  title: "Down in the Ash",
  repeatable: false,
  requirements: [],
  on_complete: [
    {:contact, "bloom_renata"},
    {:rumor, "bloom_used_up"}
  ],
  steps: [
    %{
      id: "ashfall",
      text: """
      Renata used to stand in the light you can see from here. Now she watches it
      from the Ashfall, unhurried, like someone who's stopped needing anything the
      Bloom sells. "I had a friend go up," she says. "I saw him the morning of.
      Everyone tells you they're happy. He wasn't happy — he was already gone.
      Somewhere else behind his own face, smiling at me like a light left on in an
      empty room." She looks at you. "Whatever's up that throat, it takes the
      person before it takes the body. I stopped wanting it after that."
      """,
      choices: [
        %{label: "Sit with her a while", complete: true}
      ]
    }
  ]
}
