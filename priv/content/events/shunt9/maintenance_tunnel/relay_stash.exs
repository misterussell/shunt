%Shunt.Events.Event{
  id: "shunt9_maintenance_tunnel_relay_stash",
  title: "Crew Stash",

  requirements: [
    {:knows, "maintenance_log_decoded"}
  ],

  on_complete: [
    {:scrip, 25}
  ],

  steps: [
    %{
      id: "open",
      text: """
      The decoded log spells it out plainly: the old crew kept a stash behind a
      loose panel near the relay, off the official manifest. The panel pops with
      a flathead and a little patience. Inside, a cash tin nobody ever came back
      for.
      """,
      choices: [
        %{label: "Pocket it", complete: true},
        %{label: "Leave it"}
      ]
    }
  ]
}
