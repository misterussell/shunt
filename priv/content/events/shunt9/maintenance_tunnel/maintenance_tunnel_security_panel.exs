%Shunt.Events.Event{
  id: "shunt9_maintenance_tunnel_security_panel",
  title: "Security Panel",

  steps: [
    %{
      id: "inspect",
      text: """
      A security panel sits in the corner of the maintenance tunnel, its lights blinking in a pattern that suggests it's still active. The panel is covered in dust and grime, but you can see that it has several buttons and a small screen displaying a series of numbers.
      """,
      choices: [
        %{label: "Examine panel", next: "panel"},
        %{label: "Leave it alone"}
      ]
    },
    %{
      id: "panel",
      text: """
      The panel seems to be online. If you had a working ghostdeck you could try and catch a fragmet of Lattice traffic.
      """,
      choices: [
        %{label: "You'll return when you have a working ghostdeck"},
      ]
    }
  ]
}
