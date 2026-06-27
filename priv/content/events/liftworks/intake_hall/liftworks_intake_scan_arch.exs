%Shunt.Events.Event{
  id: "liftworks_intake_scan_arch",
  title: "The Scan Arch",

  steps: [
    %{
      id: "watch",
      text: """
      You watch the queue feed through the arch. It reads everyone — papers,
      faces, the tags riding under their skin — and decides in the time it takes
      to step through. Current-spec, maintained, nothing you could talk your way
      past. The man ahead of you is waved back without a word.
      """,
      choices: [
        %{label: "Look for the seams", next: "seams"},
        %{label: "Get in line like everyone else"}
      ]
    },
    %{
      id: "seams",
      text: """
      Every system this clean was installed by someone, and someone always cuts
      a corner. The arch has a blind spot — it would — but finding it isn't a
      thing you do standing in line. You'd need to talk to whoever's worked it.
      The market row, maybe. People who know machines tend to loiter near them.
      """,
      choices: [
        %{label: "Ask around the row", complete: true}
      ]
    }
  ]
}
