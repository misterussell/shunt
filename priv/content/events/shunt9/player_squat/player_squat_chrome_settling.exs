%Shunt.Events.Event{
  id: "shunt9_player_squat_chrome_settling",
  title: "Settling In",
  repeatable: false,

  # The first Chrome Load foreshadowing beat — fires once you're carrying real chrome. Mild and
  # ominous; it plants the harvest thread (the wire reads you) without revealing anything.
  requirements: [
    {:chrome_load_at_least, 15}
  ],

  steps: [
    %{
      id: "night",
      text: """
      You wake in the dark and lie still, taking inventory of yourself. The graft's seam
      itches where it shouldn't, a low insect hum you feel more than hear — not pain, just
      the sense of something under the skin that keeps its own hours. Earlier, at the
      checkpoint, a reader's eye had drifted to you and stayed a half-second too long, the
      way it doesn't for meat. You tell yourself it's nothing. The hum doesn't agree.
      """,
      choices: [
        %{label: "Try to sleep", complete: true}
      ]
    }
  ]
}
