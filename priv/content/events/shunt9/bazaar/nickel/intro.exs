%Shunt.Events.Event{
  id: "shunt9_bazaar_nickel_intro",
  title: "Nickel",

  on_complete: [
    {:npc_progression, "shunt9_bazaar_nickel", 1}
  ],

  steps: [
    %{
      id: "corner",
      text: """
      No stall, no shelf — just a thin man leaning in the gap between two pitches
      where the work lamps don't quite reach, turning a credit chit over his
      knuckles. He watches you the way a man watches the door. "You're carrying
      light. Good. Heavy pockets get noticed down here." A thin smile. "Nickel.
      I move the small stuff. Chits, markers, the odd thing that shouldn't be sold
      where the cameras still work."
      """,
      choices: [
        %{label: "What's your line?", next: "line"},
        %{label: "Not interested", next: "pass"}
      ]
    },
    %{
      id: "line",
      text: """
      "Hot goods want the right hands. You lift something warm off a run, Rook's
      desk pays serious — but Rook asks where it came from. Me?" The chit
      disappears and reappears. "I don't ask. Smaller cut, fewer questions. And
      friendly advice, free: every warm thing you carry, the Latticework feels it.
      Heat's a tab, friend. Sooner or later somebody collects."
      """,
      choices: [
        %{label: "I'll remember that", complete: true}
      ]
    },
    %{
      id: "pass",
      text: """
      "Course not. Nobody's interested." Nickel goes back to his chit. "Till
      they're holding something warm and the whole platform's looking at them.
      Then everybody's interested." He tips his head at the shadows. "I'm in the
      gap. I don't move. You'll find me."
      """,
      choices: [
        %{label: "Move on", complete: true}
      ]
    }
  ]
}
