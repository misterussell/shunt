%Shunt.Events.Event{
  id: "winnow_mira_intro",
  title: "One Week Further In",
  repeatable: false,
  requirements: [],
  on_complete: [
    {:contact, "winnow_mira"},
    {:rumor, "winnow_the_door"}
  ],
  steps: [
    %{
      id: "line",
      text: """
      She grabs your sleeve the moment she places you as new. "Did they tell you when? When
      they fix us? I was almost listed, I did everything, I don't understand why it wouldn't
      take —" Mira's a week ahead of you and coming apart. "They keep saying spoiled like
      it's a thing you get over. There's a foreman, Edda, she won't even look at me." Her
      voice drops, conspiratorial, terrified. "I heard the wardens talking. There's a room
      up on the Gantry they don't go in. That's where it comes from, the quota, the number
      that decides who — " She can't finish it. "If I make the number they'll fix me. That's
      right, isn't it? If I'm useful enough they'll send me up proper." She wants you to
      say yes. You've been here an hour and you already can't.
      """,
      choices: [
        %{label: "Don't lie to her", complete: true}
      ]
    }
  ]
}
