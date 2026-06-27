%Shunt.Events.Event{
  id: "shunt9_power_relay_tap",
  title: "Relay Tap",

  on_complete: [
    {:rumor, "missing_shipments"}
  ],

  steps: [
    %{
      id: "tap",
      text: """
      You slot into the relay's traffic feed and let it run. Most of it is noise —
      load balancing, automated handshakes, heat dumps from the transformers. Then
      a freight routing packet surfaces, timestamped three weeks back. Corporate
      origin. Destination: Shunt 9. Quantity: significant. No corresponding entry
      in any local registry you've ever looked at.
      """,
      choices: [
        %{label: "Log the packet", complete: true},
        %{label: "Close the feed"}
      ]
    }
  ]
}
