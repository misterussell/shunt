%Shunt.Events.Event{
  id: "shunt9_burned_platform_scorched_records",
  title: "Scorched Records",

  steps: [
    %{
      id: "inspect",
      text: """
      A metal box has been pushed against the far wall, half under
      a collapsed beam. Someone moved it there intentionally — you
      can see the drag marks. The lid is warped from heat, but it
      opens.
      """,
      choices: [
        %{label: "Look inside", next: "inside"},
        %{label: "Leave it"}
      ]
    },
    %{
      id: "inside",
      text: """
      Maintenance logs from before the fire. Most of the pages are
      ash, barely held together. What survives: work orders,
      materials requests, crew names. One page is intact — a shift
      roster from the week of the incident. Nothing on it explains
      what happened.

      Someone went through this box after the fire. The intact page
      is too clean.
      """,
      choices: [
        %{label: "Set it back. Someone may come looking."}
      ]
    }
  ]
}
