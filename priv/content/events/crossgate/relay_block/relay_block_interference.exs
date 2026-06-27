%Shunt.Events.Event{
  id: "crossgate_relay_block_interference",
  title: "Active Interference",

  steps: [
    %{
      id: "inspect",
      text: """
      The relay room hums at a frequency that sits wrong in the
      chest. Two separate signal sources are competing in here —
      you can feel the interference before you can identify it.
      The original Syndicate infrastructure and something newer,
      something that doesn't quite match the room's other
      equipment.
      """,
      choices: [
        %{label: "Find the second source", next: "source"},
        %{label: "Leave it alone"}
      ]
    },
    %{
      id: "source",
      text: """
      Tucked behind the original relay rack — a secondary unit,
      newer manufacture, running on its own power cell. Someone
      installed this deliberately, and recently. The housing has
      a small mark on it: a circular pattern of dots that you
      don't recognize yet, but that looks like it means something
      to someone.
      """,
      choices: [
        %{label: "Leave it where it is. Something to remember."}
      ]
    }
  ]
}
