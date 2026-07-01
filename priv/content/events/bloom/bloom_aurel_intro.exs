%Shunt.Events.Event{
  id: "bloom_aurel_intro",
  title: "You Could Be Listed",
  repeatable: false,
  requirements: [],
  on_complete: [
    {:contact, "bloom_aurel"},
    {:knowledge, "bloom_ascent_pitch"}
  ],
  steps: [
    %{
      id: "throat",
      text: """
      Aurel finds you before you find him, which is its own kind of message. He
      remembers your name, asks after where you came from, listens like it matters.
      "People think the throat's a wall," he says, warm, walking you toward the
      light of it. "It isn't. It's a door, and I'm the one who opens it. The Bloom
      makes you fight each other for the idea that only a few go up. But I've seen
      you. You could be listed." He says it like a gift. Standing in his warmth,
      it's very hard to remember to be afraid.
      """,
      choices: [
        %{label: "Thank him", complete: true}
      ]
    }
  ]
}
