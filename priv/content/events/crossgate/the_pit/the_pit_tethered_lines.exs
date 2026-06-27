%Shunt.Events.Event{
  id: "crossgate_the_pit_tethered_lines",
  title: "Tethered Lines",

  steps: [
    %{
      id: "inspect",
      text: """
      Looking up from the lowest level, The Pit shows its engineering —
      or lack of it. Rope lines and cable runs stretch between the
      improvised floors, moving laundry, goods, and messages between
      levels without requiring anyone to climb. The whole structure
      creaks when more than a few people move at once.
      """,
      choices: [
        %{label: "Watch the system work", next: "watch"},
        %{label: "Keep moving"}
      ]
    },
    %{
      id: "watch",
      text: """
      It works, after a fashion. A basket of food rises to the third
      level via a counterweight rig someone salvaged from the track
      machinery. A child on the fourth level lowers a message on a
      string to someone waiting below. This is how people who live here
      live here — continuously inventing the infrastructure they need.
      """,
      choices: [
        %{label: "Keep moving."}
      ]
    }
  ]
}
