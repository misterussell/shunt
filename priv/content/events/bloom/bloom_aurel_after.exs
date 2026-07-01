%Shunt.Events.Event{
  id: "bloom_aurel_after",
  title: "The Same Warm Smile",
  repeatable: false,
  requirements: [
    {:knows, "bloom_truth_substrate"}
  ],
  on_complete: [
    {:knowledge, "bloom_aurel_seen_through"}
  ],
  steps: [
    %{
      id: "throat",
      text: """
      Aurel greets you exactly as warmly as the first time — remembers your name,
      asks after you, means it. That's what undoes you now. He isn't a monster
      hiding it. He genuinely likes the people he signs up the throat, genuinely
      believes he's opening a door, and hands them through into the wire smiling,
      because nobody ever told him where the door goes and he never once asked.
      "You're so close," he says, delighted for you. "I can feel it. You could go
      up any day now." And he can, and you could, and he has no idea that's a
      sentence.
      """,
      choices: [
        %{label: "Say nothing", complete: true}
      ]
    }
  ]
}
