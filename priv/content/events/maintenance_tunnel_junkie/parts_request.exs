%Shunt.Events.Event{
  id: "shunt9_maintenance_tunnel_junkie_parts_request",
  title: "Tunnel Junkie",

  # TODO: add {:inventory, "battered_relay_coil", 1} to this on_complete list (event-level
  # reward, processed by Shunt.Effects' existing {:inventory, key, delta} clause), and delete
  # the step-level `rewards:` block on the "report" step below. Per the decided architecture
  # in priv/docs/SHUNT_npc_architecture.md (lines 439-442): step-level `rewards` is a
  # never-implemented mechanism superseded by on_complete — don't build both.
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
      ],
      rewards: [
        %{
          type: :item,
          key: "battered_relay_coil",
          quantity: 1
        }
      ]
    }
  ]
}
