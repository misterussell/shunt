%Shunt.Events.Event{
  id: "liftworks_cold_stair_back_route",
  title: "The Cold Stair",

  on_complete: [
    {:knowledge, "liftworks_back_route"}
  ],

  steps: [
    %{
      id: "climb",
      text: """
      You take the stair the way Proxy described it — slow, hand on the cold
      rail, counting flights. The scan arch's hum fades two landings up and
      doesn't come back. Bare cable runs alongside you, spliced and re-spliced,
      somebody's long quiet project. The dark is doing you a favor.
      """,
      choices: [
        %{label: "Keep climbing", next: "top"},
        %{label: "Head back down"}
      ]
    },
    %{
      id: "top",
      text: """
      The stair lets out behind the lift machinery — past the reader, past the
      desks, beside the open freight car itself. No one asking for papers because
      no one comes this way. You learn the turns by heart. Next time you won't
      need the dark to find it.
      """,
      choices: [
        %{label: "Mark the route", complete: true}
      ]
    }
  ]
}
