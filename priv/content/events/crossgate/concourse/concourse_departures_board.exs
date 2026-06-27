%Shunt.Events.Event{
  id: "crossgate_concourse_departures_board",
  title: "Departures Board",

  steps: [
    %{
      id: "inspect",
      text: """
      The original departures board still hangs from the vaulted ceiling,
      its flip-tile mechanism long dead, destinations locked in place at
      whatever the last scheduled departure read. Someone has repurposed
      the frame — community notices, job postings, and wanted notices have
      been stapled and pinned over the original tiles until it looks less
      like infrastructure and more like a city.
      """,
      choices: [
        %{label: "Read the notices", next: "read"},
        %{label: "Keep moving"}
      ]
    },
    %{
      id: "read",
      text: """
      Work for hire. Debt collection notices. A hand-lettered warning
      about a crew operating out of the lower concourse — no names, just
      a description and a recommendation not to carry anything valuable
      alone down there.

      Near the bottom, half-covered: a Syndicate notice in the official
      red print. "ALL OPERATORS: toll adjustments effective next cycle.
      See Ratchet at the gate."
      """,
      choices: [
        %{label: "Something to know."}
      ]
    }
  ]
}
