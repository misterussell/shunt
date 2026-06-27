%Shunt.Events.Event{
  id: "crossgate_cold_storage_unclaimed_crate",
  title: "Unclaimed Crate",

  steps: [
    %{
      id: "inspect",
      text: """
      A crate near the back of the main storage room has a yellow tag
      on it — unclaimed, past the collection window. The consignment
      slip is still attached, but the collection name has been scratched
      out. Whoever was supposed to pick this up either couldn't or
      didn't want to be connected to it.
      """,
      choices: [
        %{label: "Read the consignment slip", next: "slip"},
        %{label: "Leave it alone"}
      ]
    },
    %{
      id: "slip",
      text: """
      The scratched-out name is gone, but the consignment origin is
      still readable: routed through a Midgrid transit hub three weeks
      ago. The contents are listed as "calibration equipment" — the
      kind of vague description that means the operator paid extra
      for it to be vague.

      The crate will go to auction in a few days. Whatever's in it,
      someone decided it wasn't worth the risk of showing up to
      collect.
      """,
      choices: [
        %{label: "Worth watching the auction."}
      ]
    }
  ]
}
