%Shunt.Events.Event{
  id: "shunt9_freight_tunnel_ghost_route",
  title: "The Ghost Route",
  repeatable: false,

  on_complete: [
    {:scrip, 120},
    {:heat, 10},
    {:knowledge, "freight_route_worked"}
  ],

  steps: [
    %{
      id: "alcove",
      text: """
      The crates in the staging alcove are real enough — corporate hardware under
      shrink-wrap, tagged in a shorthand that only reads if you already know the
      route. You do now. Vex signs the manifests that clear this tunnel, and Vex
      is into a corporate creditor deeper than a contractor's wage covers. Dex
      brokers the gap. The cargo doesn't stop for either of them.
      """,
      choices: [
        %{label: "Lean on Vex", next: "lean"},
        %{label: "Cut yourself in quiet", next: "quiet"},
        %{label: "Leave it moving"}
      ]
    },
    %{
      id: "lean",
      text: """
      You don't threaten Vex. You just let him understand that you can read the
      shorthand now, and that a man clearing corporate debt on transit pay is a man
      with something to lose. He folds fast — too fast, like he's been waiting for
      someone to make the ask. A cut comes off the next shipment before it moves,
      and Vex pretends he didn't watch you take it.
      """,
      choices: [
        %{label: "Pocket the cut", complete: true}
      ]
    },
    %{
      id: "quiet",
      text: """
      No leaning, no leverage — just a crate cracked at the seam while the alcove
      sits empty, enough lifted that the count still squares if nobody's counting
      careful. You learn the route doing it: when the tunnel goes clear, how long
      staging sits, which tags mean nobody's coming back soon. Worth more than the
      one haul.
      """,
      choices: [
        %{label: "Walk it out", complete: true}
      ]
    }
  ]
}
