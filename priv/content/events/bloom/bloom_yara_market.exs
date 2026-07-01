%Shunt.Events.Event{
  id: "bloom_yara_market",
  title: "Working the Room",
  repeatable: false,
  requirements: [
    {:has_rumor, "bloom_bought_name"}
  ],
  on_complete: [
    {:knowledge, "bloom_season_stoked"},
    {:npc_loyalty, "bloom_yara", 4}
  ],
  steps: [
    %{
      id: "trade",
      text: """
      Yara shows you how the market really works — not buying names, but moving
      them. You plant a story here, confirm one there, let a third slip in front of
      the wrong ear, and by evening a name that was rising is falling and everyone
      swears they always knew. "That," Yara says, watching it happen with a
      professional's calm, "is the season turning. Do it enough and the whole
      Bloom gets loud — everyone knifing everyone, nobody watching the throat too
      close." She smiles. "Which is when the interesting work gets done."
      """,
      choices: [
        %{label: "Turn the season", complete: true}
      ]
    }
  ]
}
