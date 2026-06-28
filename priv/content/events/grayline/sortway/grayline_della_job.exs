%Shunt.Events.Event{
  id: "grayline_della_job",
  title: "Work It Off",
  repeatable: false,

  requirements: [
    {:knows, "court_known"}
  ],

  on_complete: [
    {:knowledge, "midgrid_echo"},
    {:heat, 16},
    {:npc_loyalty, "grayline_della", 5}
  ],

  steps: [
    %{
      id: "offer",
      text: """
      Della finds you after you've been to the Court. "Sat the bench, heard the
      number," she says. "You don't have to pay it in scrip. Court always needs
      hands that aren't on any roster — yours qualify." She lets that sit. "Run
      what they hand you. Don't read it. Don't get read doing it. Do that a few
      times and Quire writes your echo herself, no charge. The charge is just
      the risk, all of it on you."
      """,
      choices: [
        %{label: "I'll run it", next: "run"},
        %{label: "I'll find the scrip instead"}
      ]
    },
    %{
      id: "run",
      text: """
      So you run it. A sealed block to a stall that isn't a stall. A flagged
      client walked past a reader during the one minute Sana said it would be
      looking elsewhere. A name carried in your head because nothing carried in
      your hand can be found. Each one leaves a little more heat clinging to you
      and a little less doubt in the Court about what you're for.
      """,
      choices: [
        %{label: "Collect what you earned", next: "paid"}
      ]
    },
    %{
      id: "paid",
      text: """
      Quire doesn't make a ceremony of it. "You carried weight and didn't drop
      it," she says, and turns to the terminal. When she turns back you're in the
      registry — a past assembled out of other people's edges, clean enough to
      pass. "You're someone now. You earned the someone. Spend it before the heat
      you're wearing spends you."
      """,
      choices: [
        %{label: "You're holding an echo", complete: true}
      ]
    }
  ]
}
