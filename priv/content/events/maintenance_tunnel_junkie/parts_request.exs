%Shunt.Events.Event{
  id: "shunt9_maintenance_tunnel_junkie_parts_request",
  title: "Tunnel Junkie",

  on_complete: [{:npc_progression, "shunt9_maintenance_tunnel_junkie", 1}],

  steps: [
    %{
      id: "greet",
      text: """
      The junkie looks up, expectant. Back again. Good sign, that is.
      """,
      choices: [
        %{label: "Did you find anything?", next: "report"},
        %{label: "Just passing through."}
      ]
    },
    %{
      id: "report",
      text: """
      They dig a battered relay coil out of their coat. "Saw this rattling around.
      Figured you'd know what to do with it better than I would."
      """,
      choices: [
        %{label: "Take the coil.", complete: true}
      ]
    }
  ]
}
