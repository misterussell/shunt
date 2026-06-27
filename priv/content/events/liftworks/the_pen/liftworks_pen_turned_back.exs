%Shunt.Events.Event{
  id: "liftworks_pen_turned_back",
  title: "Turned Back",

  steps: [
    %{
      id: "bench",
      text: """
      A man on the bench has a permit in his hand and nowhere to be. "Read fine
      yesterday," he tells no one. "Read fine for a year." He turns it over like
      the mark might come back. "Then the registry blinks and you're a flag, and
      a flag waits here until someone upstairs forgets about you."
      """,
      choices: [
        %{label: "What happens to the flagged?", next: "fate"},
        %{label: "Leave him to it"}
      ]
    },
    %{
      id: "fate",
      text: """
      He laughs, short. "Down. Always down. Nobody gets escorted *up* for being
      a problem." He pockets the dead permit. "Whatever you're carrying to get
      through that arch — make sure it's the kind that doesn't blink."
      """,
      choices: [
        %{label: "Noted"}
      ]
    }
  ]
}
