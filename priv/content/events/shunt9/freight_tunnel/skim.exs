%Shunt.Events.Event{
  id: "shunt9_freight_tunnel_skim",
  title: "Skim the Shipment",
  repeatable: true,

  requirements: [
    {:knows, "freight_route_worked"}
  ],

  on_complete: [
    {:scrip, 18},
    {:heat, 2}
  ],

  steps: [
    %{
      id: "lift",
      text: """
      The staging alcove sits empty between runs, the way you know it will now. A
      crate near the back gives at the seam. You take a little — never enough to
      throw the count, never enough that Vex has to notice on paper. The cargo
      keeps moving. So does your cut.
      """,
      choices: [
        %{label: "Take a little", complete: true},
        %{label: "Not this time"}
      ]
    }
  ]
}
