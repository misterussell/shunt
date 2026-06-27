%Shunt.Events.Event{
  id: "shunt9_scrap_yard_watchman",
  title: "Scrap Yard Watchman",

  on_complete: [
    {:rumor, "vex_debts"}
  ],

  steps: [
    %{
      id: "approach",
      text: """
      A transit authority contract guard is leaning against the scrap yard fence,
      nursing something hot from a bent tin cup. Off the clock by the look of it.
      He watches you approach without moving.

      "You're not lost, are you."
      """,
      choices: [
        %{label: "Looking for work", next: "work"},
        %{label: "Wrong place"}
      ]
    },
    %{
      id: "work",
      text: """
      He looks you over slowly. "Work's where you make it around here." He takes
      a long drink. "Word to the wise, though — don't get in bed with Vex. Man's
      been clearing debts with a creditor none of us have heard of. Whatever deal
      he made, it wasn't his to make."
      """,
      choices: [
        %{label: "File that away", complete: true},
        %{label: "Who's Vex?", next: "who"}
      ]
    },
    %{
      id: "who",
      text: """
      "Transit authority, same as me. Except he's the kind that looks the other
      way if the price is right." He shrugs. "Or maybe the price wasn't right and
      now someone else is setting his terms for him."
      """,
      choices: [
        %{label: "Understood", complete: true}
      ]
    }
  ]
}
