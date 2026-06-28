%Shunt.Events.Event{
  id: "grayline_quire_intro",
  title: "Take a Number",
  repeatable: false,

  on_complete: [
    {:knowledge, "court_known"}
  ],

  steps: [
    %{
      id: "counter",
      text: """
      Your number comes up. The woman behind the counter is unhurried and exact,
      a clerk's manner worn smooth by repetition. This is Quire. "You came up the
      lift," she says, not a question. "The lift was the easy gate. It moves your
      body. The hard gate is the one that moves your record, and that gate is
      this counter."
      """,
      choices: [
        %{label: "And the price?", next: "price"}
      ]
    },
    %{
      id: "price",
      text: """
      "An echo. A past the grid already believes it remembers — credit, history,
      a clean read at any line in Midgrid." She folds her hands. "We don't sell
      forgeries. A forgery is a lie the system catches. We write truth into the
      system so there's nothing left to catch. The price is scrip, or work, or
      something you have that I want. People always have something." A small,
      administrative smile. "Sit with it. The bench is free. Nothing else is."
      """,
      choices: [
        %{label: "I'll think on it", complete: true}
      ]
    }
  ]
}
