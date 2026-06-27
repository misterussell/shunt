%Shunt.Events.Event{
  id: "shunt9_food_stalls_vendor_board",
  title: "Vendor Board",

  steps: [
    %{
      id: "inspect",
      text: """
      A corkboard nailed to the support column at the end of the row,
      dense with handwritten notices. Debt markers, trade offers,
      warnings. Half of it's been torn down and re-papered so many
      times the board is more layered paper than cork.
      """,
      choices: [
        %{label: "Read through it", next: "read"},
        %{label: "Keep moving"}
      ]
    },
    %{
      id: "read",
      text: """
      Most of it is between people you don't know yet. There's a
      standing offer for stripped relay coils — ten scrip, no
      questions — posted by someone signing themselves only as a
      scrap unit number.

      Near the bottom, in a cleaner hand than the rest: "RELAY
      FEED THREE — IF YOU KNOW WHAT IT MEANS, YOU ALREADY KNOW
      WHERE TO LOOK."
      """,
      choices: [
        %{label: "File that away."}
      ]
    }
  ]
}
