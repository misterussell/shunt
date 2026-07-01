%Shunt.Events.Event{
  id: "windlass_ratchet_engine_job",
  title: "Wake the Engine",
  repeatable: false,

  requirements: [
    {:has_rumor, "windlass_stalled_on_purpose"}
  ],

  on_complete: [
    {:npc_loyalty, "windlass_ratchet", 3}
  ],

  steps: [
    %{
      id: "ask",
      text: """
      "You mean it, then." Ratchet sizes you up. "Engine room's through the blast
      door, and the drive throws heat that'll cook you without the right chrome in
      your skin. Tallow works out of the casting pit — she'll fit you, for a price,
      and she does clean work. Once you can stand the heat, the governor needs a
      relay bank reseated. I'll have the parts pulled. You bring the hands and a
      soldering iron that isn't garbage."
      """,
      choices: [
        %{label: "Consider it done", next: "why"}
      ]
    },
    %{
      id: "why",
      text: """
      "One more thing." He lowers his voice under the floor-noise. "When you get
      the plate off, look at the governor before you fix it. Really look. What they
      did to it is evidence, and evidence has a way of going missing once the
      freight's climbing and everyone's happy again. See it with your own eyes
      first. Then wake the engine."
      """,
      choices: [
        %{label: "I'll see it for myself", complete: true}
      ]
    }
  ]
}
