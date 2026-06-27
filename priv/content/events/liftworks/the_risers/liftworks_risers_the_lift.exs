%Shunt.Events.Event{
  id: "liftworks_risers_the_lift",
  title: "The Way Up",

  steps: [
    %{
      id: "stand",
      text: """
      You stand at the open car and the reader blinks for clearance you don't
      have. Up the shaft, light leaks down from a stratum you've only ever
      fenced goods out of. The Midgrid. Close enough now to feel the draft off it.
      """,
      choices: [
        %{label: "How do people get through?", next: "ways"},
        %{label: "Step back"}
      ]
    },
    %{
      id: "ways",
      text: """
      Three kinds of people ride this lift. The ones who paid Stamp and carry a
      permit the reader trusts. The ones who taught the arch to lie and ride on a
      spoofed tag. And the ones who never touch the reader at all, because they
      came up the Cold Stair. You're none of those. Yet.
      """,
      choices: [
        %{label: "Decide how you'll go up"}
      ]
    }
  ]
}
