%Shunt.Events.Event{
  id: "winnow_tithe_wake",
  title: "The Part That Knows",
  repeatable: false,
  requirements: [
    {:contact_known, "winnow_tithe"}
  ],
  on_complete: [
    {:knowledge, "winnow_caste_stirring"}
  ],
  steps: [
    %{
      id: "carry",
      text: """
      You bring Tithe out to the belt at shift change — the part of her that still walks,
      leaning on you, in front of the whole caste. She doesn't make a speech. She can't hold
      one together. She just stands there, obviously half-taken and obviously still there,
      and says the thing they've all spent their whole shifts not thinking: "I'm what's up
      top. All of you. This is where you go. And it — " she taps her own temple, where the
      shunt sits wrong " — it still knows. It's not sleep up there. It's not rest. It's
      work, and you can feel it, and you never stop." The belt runs on. But hands have
      slowed all down the line, and people are looking at each other for the first time,
      and something that was dead-asleep in the Winnow has opened one eye.
      """,
      choices: [
        %{label: "Let them see her", complete: true}
      ]
    }
  ]
}
