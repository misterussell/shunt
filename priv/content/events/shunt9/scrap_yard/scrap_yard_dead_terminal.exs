%Shunt.Events.Event{
  id: "shunt9_scrap_yard_dead_terminal",
  title: "Dead Terminal",

  on_complete: [{:knowledge, "shunt9_yard_manifest_found"}],

  steps: [
    %{
      id: "inspect",
      text: """
      A terminal unit is half-buried in a scrap heap, screen cracked
      and casing warped, but the status light still pulses. Whatever
      kept this yard running officially, some part of it hasn't gotten
      the message yet.
      """,
      choices: [
        %{label: "Try to read the screen", next: "screen"},
        %{label: "Leave it"}
      ]
    },
    %{
      id: "screen",
      text: """
      The display cycles through error states too fast to follow, but
      underneath the noise you catch fragments — inventory strings,
      old manifest entries. There's still a signal here. With a
      ghostdeck and some patience, you might be able to pull
      something useful out of it.
      """,
      choices: [
        %{label: "Something to look into.", complete: true}
      ]
    }
  ]
}
