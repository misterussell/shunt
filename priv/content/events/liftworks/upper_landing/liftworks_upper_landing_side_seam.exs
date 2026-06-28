%Shunt.Events.Event{
  id: "liftworks_upper_landing_side_seam",
  title: "The Side Door",
  repeatable: false,

  on_complete: [
    {:knowledge, "grayline_seam"}
  ],

  steps: [
    %{
      id: "watched",
      text: """
      You're not the only one standing where the turnstiles say stop. A woman in
      a scraped-down work jacket has been reading you read the line. She doesn't
      come over. She tips her head — not at the turnstiles, at the wall beside
      them, where a service door sits under a dead reader nobody's bothered to
      replace.
      """,
      choices: [
        %{label: "Go to her", next: "told"},
        %{label: "Not yet"}
      ]
    },
    %{
      id: "told",
      text: """
      "Front way wants a name you don't have," she says, quiet, not unkind.
      "Side way doesn't ask. It only goes one place — the Grayline. Everybody up
      here who came up like you did." She's already moving toward the door. "It's
      not Midgrid. It's the edge of it. But it's a floor with your weight on it,
      and that beats the lift."
      """,
      choices: [
        %{label: "Follow her through", complete: true}
      ]
    }
  ]
}
