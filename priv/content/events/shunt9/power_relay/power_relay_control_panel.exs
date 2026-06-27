%Shunt.Events.Event{
  id: "shunt9_power_relay_control_panel",
  title: "Control Panel",

  steps: [
    %{
      id: "inspect",
      text: """
      The relay's main control panel runs floor to ceiling along the
      inner wall, covered in switches and analog meters that haven't
      been serviced in years. Half the indicators are dead. The live
      ones show current draw across three feeds.
      """,
      choices: [
        %{label: "Read the meters", next: "meters"},
        %{label: "Leave it alone"}
      ]
    },
    %{
      id: "meters",
      text: """
      Two feeds are running normal. The third is pulling hard — more
      than any single residential block should need, more than most
      commercial operators run. Whoever's on that feed either doesn't
      know how to hide it, or doesn't care.

      The duct route points back toward the maintenance tunnel.
      """,
      choices: [
        %{label: "Worth keeping in mind."}
      ]
    }
  ]
}
