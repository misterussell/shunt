%Shunt.Events.Event{
  id: "windlass_drift_intro",
  title: "The Weather System",
  repeatable: false,

  on_complete: [
    {:knowledge, "windlass_collective_vouched"},
    {:rumor, "windlass_collective_starved"}
  ],

  steps: [
    %{
      id: "coldroom",
      text: """
      Drift is bent over a cracked deck when you come in, and she keeps working
      while she talks, the way everyone in this district seems to. "Fuse says
      you're clean. Fuse is usually right." She straightens. "So you've noticed the
      Windlass is at war and nobody's shooting. The Authority owns the grid — every
      reader, every permit, every count. We own the wires underneath it. Right now
      they're winning, because they stopped the freight."
      """,
      choices: [
        %{label: "The freight stall is aimed at you?", next: "starve"}
      ]
    },
    %{
      id: "starve",
      text: """
      "Course it is. No haul means no parts, and the Fitworks runs on parts. Stop
      the freight and the Collective starves first — they know that. Dress it up as
      an engine failure and you've got a reason to lock the grid down while you're
      at it." She taps the dead reader on the wall. "Every relay you free, every
      Authority node you crack, this district comes a little more open. Do enough of
      it and we take the whole grid back. You in? Because if you are, I've got
      somewhere better than the stair for you to sleep."
      """,
      choices: [
        %{label: "I'm in", complete: true}
      ]
    }
  ]
}
