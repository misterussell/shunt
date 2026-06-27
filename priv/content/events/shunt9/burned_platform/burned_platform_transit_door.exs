%Shunt.Events.Event{
  id: "shunt9_burned_platform_transit_door",
  title: "Transit Door",

  steps: [
    %{
      id: "inspect",
      text: """
      Set into the far wall of the platform, behind a tangle of
      collapsed signage, is a heavy security door — still sealed,
      still powered. A control panel beside it blinks a steady
      amber. Unlike the melted door, this one didn't fail. Someone
      locked it deliberately.
      """,
      choices: [
        %{label: "Examine the control panel", next: "panel"},
        %{label: "Leave it"}
      ]
    },
    %{
      id: "panel",
      text: """
      The panel is running active ICE — not vintage, not derelict.
      Updated. Whatever's on the other side, someone still cares
      about keeping it closed. A ghostdeck could reach the lock
      mechanism from here.
      """,
      choices: [
        %{label: "Something to come back to."}
      ]
    }
  ]
}
