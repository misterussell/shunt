%Shunt.Events.Event{
  id: "bloom_bevel_gloss",
  title: "The Fitting",
  repeatable: false,
  requirements: [],
  on_complete: [
    {:contact, "bloom_bevel"},
    {:knowledge, "bloom_glossed"}
  ],
  steps: [
    %{
      id: "chair",
      text: """
      Bevel works like a craftsman who loves the craft — the sheen laid clean, the
      voice tuned steadier, the face brought up to something that reads, at a
      glance, as listed. "There," he says, proud, turning the glass so you can see
      what you've become. It's good work. You look like you belong up the throat.
      There's a seam under your jaw you don't remember agreeing to, and when you
      ask, Bevel just says it's standard, everyone gets it, and moves on to
      buffing the shine.
      """,
      choices: [
        %{label: "Admire the work", complete: true}
      ]
    }
  ]
}
