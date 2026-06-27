%Shunt.Events.Event{
  id: "shunt9_scrap_yard_grit_intro",
  title: "Grit",

  on_complete: [{:npc_progression, "shunt9_scrap_yard_grit", 1}],

  steps: [
    %{
      id: "notice",
      text: """
      Someone's working a mag-rig through a pile of stripped chassis,
      sorting with the practiced speed of someone who's been at it for
      years. They glance up when your shadow crosses their pile.
      """,
      choices: [
        %{label: "Talk to them", next: "talk"},
        %{label: "Leave them to it"}
      ]
    },
    %{
      id: "talk",
      text: """
      "This section's spoken for." A pause. The mag-rig lowers. "But
      you're not here for scrap, are you. You're one of Juno's people."

      It's not quite a question.
      """,
      choices: [
        %{label: "I run my own work.", next: "own"},
        %{label: "Something like that.", next: "juno"}
      ]
    },
    %{
      id: "own",
      text: """
      "Good." The rig lifts again. "Then we won't have a problem. Name's
      Grit. You find something worth pulling, ask me first. I'll tell
      you if it's already claimed."
      """,
      choices: [
        %{label: "Fair enough.", complete: true}
      ]
    },
    %{
      id: "juno",
      text: """
      "Same answer either way. You want to pull from this yard, you
      check with me. Name's Grit." The mag-rig resumes. "Good doing
      business."
      """,
      choices: [
        %{label: "Understood.", complete: true}
      ]
    }
  ]
}
