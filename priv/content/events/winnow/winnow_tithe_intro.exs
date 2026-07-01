%Shunt.Events.Event{
  id: "winnow_tithe_intro",
  title: "What the Wire Left",
  repeatable: false,
  requirements: [],
  on_complete: [
    {:contact, "winnow_tithe"},
    {:rumor, "winnow_no_ascended_return"}
  ],
  steps: [
    %{
      id: "bench",
      text: """
      The woman at the reclaim bench works with half her attention and speaks with less,
      and every third thing she says lands like a blade. "Tithe," she says, when you ask.
      "'Cause I'm the part they didn't take." Her hands strip a dead man's port without
      looking. "Went up. Came most of the way back down. Most of me's up there now, in the
      wire, working — I can feel it working, some nights, my own hands doing sums I never
      agreed to." She fits the port into a tray. "They tell you the ascended are gone.
      Happy, gone, retired up top. Nobody comes back to say different." A long pause. "I
      came back. Not all of me. Enough to tell you: they're not gone. They're used. And
      the part that's used still knows. That's the part nobody up there wants awake."
      """,
      choices: [
        %{label: "Stay with her a while", complete: true}
      ]
    }
  ]
}
