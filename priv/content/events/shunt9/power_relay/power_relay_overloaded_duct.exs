%Shunt.Events.Event{
  id: "shunt9_power_relay_overloaded_duct",
  title: "East Duct Junction",

  steps: [
    %{
      id: "inspect",
      text: """
      The east duct is running noticeably hotter than the others —
      you can feel it from a meter away. The conduit housing has
      discolored from sustained heat.
      """,
      choices: [
        %{label: "Touch the housing", next: "touch"},
        %{label: "Leave it alone"}
      ]
    },
    %{
      id: "touch",
      text: """
      Hot enough to sting through an insulating layer. The housing
      seam is warped from the sustained draw. This has been running
      like this long enough to leave marks. Whoever's on the other
      end of this line isn't being careful.
      """,
      choices: [
        %{label: "Someone should know about this."}
      ]
    }
  ]
}
