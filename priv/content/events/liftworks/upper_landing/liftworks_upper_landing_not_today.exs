%Shunt.Events.Event{
  id: "liftworks_upper_landing_not_today",
  title: "Not Today",

  steps: [
    %{
      id: "stand",
      text: """
      You stand on Midgrid floor for the first time. It's quieter than you
      expected, and colder, and it smells of nothing — no oil, no crowd, no
      water in the walls. People move past with somewhere to be and the easy
      blindness of those who've never had to watch a door.
      """,
      choices: [
        %{label: "Go further in", next: "stop"},
        %{label: "Take it in"}
      ]
    },
    %{
      id: "stop",
      text: """
      A guard's eyes find you, weigh you, and move on — for now. The corridor
      runs on toward turnstiles you have no answer for yet. Not today. But you've
      stood here, and the Underbelly will feel smaller when you go back down. It
      always does, once you've seen the next floor up.
      """,
      choices: [
        %{label: "Ride back down"}
      ]
    }
  ]
}
