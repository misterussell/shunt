%Shunt.Events.Event{
  id: "bloom_yara_intro",
  title: "The Price of a Name",
  repeatable: false,
  requirements: [],
  on_complete: [
    {:contact, "bloom_yara"},
    {:rumor, "bloom_bought_name"}
  ],
  steps: [
    %{
      id: "booth",
      text: """
      Yara prices you before you've sat down — a glance, a number she doesn't say
      out loud but you can feel her set. "You think ascent's about being the best,"
      she says, not unkindly. "It isn't. It's about being the one somebody decides
      to spend on. A name gets bought up — cleaned, vouched, placed — and then the
      throat calls it, and everyone claps like it was earned." She spreads her
      hands. "I sell names. I'd know a bought one."
      """,
      choices: [
        %{label: "Ask what yours would cost", complete: true}
      ]
    }
  ]
}
