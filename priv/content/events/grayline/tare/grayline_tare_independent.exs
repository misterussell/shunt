%Shunt.Events.Event{
  id: "grayline_tare_independent",
  title: "Word of an Independent",
  repeatable: false,

  requirements: [
    {:has_rumor, "cal_was_court"}
  ],

  on_complete: [
    {:knowledge, "cutaway_found"}
  ],

  steps: [
    %{
      id: "ask",
      text: """
      You'd heard it in the market noise — someone writing echoes the Court
      doesn't bless. You spend a little patience and a little scrip asking the
      right stalls the wrong-sounding questions, until a fabric-seller stops
      restacking long enough to answer.
      """,
      choices: [
        %{label: "Where do they work?", next: "where"}
      ]
    },
    %{
      id: "where",
      text: """
      "Behind here. There's a gap the builders left between this hall and the
      next — a cutaway. Cal works it." The seller goes back to the bolts of cloth.
      "Used to be Court. Now they're the reason Reyes walks the line so much. You
      didn't hear it from a stall." You have the gap fixed in your head now: a
      door that isn't a door, around the back of the Tare.
      """,
      choices: [
        %{label: "Find the Cutaway", complete: true}
      ]
    }
  ]
}
