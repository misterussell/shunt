%Shunt.Events.Event{
  id: "shunt9_maintenance_tunnel_junkie",
  title: "Tunnel Junkie",

  steps: [
    %{
      id: "inspect",
      text: """
      A figure crouches in the shadows, hunched over a pile of discarded tech.
      They look up as you approach, eyes strung out and curious.
      """,
      choices: [
        %{label: "Talk to them", next: "talk"},
        %{label: "Leave them alone"}
      ]
    },
    %{
      id: "talk",
      text: """
      "I've seen you digging around in the filth. You finding anything good?"
      """,
      choices: [
        %{label: "Nothing yet, just looking for parts. Trying to make some scrip.", next: "parts"}
      ]
    },
    %{
      id: "parts",
      text: """
      I'll keep an eye out for you.
      """,
      choices: [
        %{label: "Thanks."}
      ]
    }
  ]
}
