%Shunt.Events.Event{
  id: "crossgate_transit_tunnel_old_signage",
  title: "Old Signage",

  steps: [
    %{
      id: "inspect",
      text: """
      Faded transit signage lines both walls — destinations, platform
      numbers, transfer instructions. Most of the places named haven't
      existed in this form for decades. One board near the ceiling still
      has power, cycling through departure information for routes that
      haven't run since the interchange collapsed.
      """,
      choices: [
        %{label: "Read the destinations", next: "read"},
        %{label: "Keep moving"}
      ]
    },
    %{
      id: "read",
      text: """
      Platform 7 — Upper Midgrid Connector. Platform 12 — Spire
      Transfer. Platform 3 — Southline Express.

      None of these platforms exist anymore — not accessible from
      here, anyway. The Crossgate absorbed whatever was left when the
      line came down. The board doesn't know. It's just doing its job.
      """,
      choices: [
        %{label: "Leave it running."}
      ]
    }
  ]
}
