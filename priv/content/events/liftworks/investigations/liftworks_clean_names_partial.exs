%Shunt.Events.Event{
  id: "liftworks_clean_names_partial",
  title: "Wrong Angle",
  repeatable: true,

  on_complete: [
    {:rumor, "cargo_discrepancy"}
  ],

  steps: [
    %{
      id: "partial",
      text: """
      The pieces point at something, but the angle isn't right. The Transfer
      Row manifests keep pulling your eye — goods that don't reconcile,
      numbers that run short. It feels like the thread.

      It isn't. The cargo is a different kind of sloppy. Whatever is moving
      through this checkpoint off the books has no manifest to be sloppy on.
      """,
      choices: [
        %{label: "Keep looking", complete: true}
      ]
    }
  ]
}
