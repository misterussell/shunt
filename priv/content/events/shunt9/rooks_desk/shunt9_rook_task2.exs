%Shunt.Events.Event{
  id: "shunt9_rook_task2",
  title: "The Closed-Hands Rate",

  on_complete: [
    {:knowledge, "rook_task2"},
    {:npc_progression, "shunt9_rook", 1}
  ],

  steps: [
    %{
      id: "open",
      text: """
      The marker business is long settled, and Rook has stopped watching your
      hands when you come to the desk. The ledger is open to a page you can't
      read. "You've moved a fair bit through the quiet channel, and every count
      came back honest." He turns the book a half-inch toward you, then away.
      "The Syndicate keeps a rate for its own. I'm putting you on it."
      """,
      choices: [
        %{label: "What's the rate?", next: "rate"},
        %{label: "Why me?", next: "why"}
      ]
    },
    %{
      id: "rate",
      text: """
      "I stop taking a cut worth mentioning. Whatever you bring, near all of it
      comes back to you — the Closed-Hands rate, same as any name in the book."
      Rook closes the ledger. "It costs you nothing but this: a hand that's closed
      stays closed. What moves through this desk gets described nowhere else."
      """,
      choices: [
        %{label: "Understood", complete: true}
      ]
    },
    %{
      id: "why",
      text: """
      "Because I know who owes what, and after all this, you don't owe me a
      thing." A short pause. "That's rarer than clean scrip down here. Someone I
      don't have to account for is worth more to the Syndicate than one I do."
      """,
      choices: [
        %{label: "The hand stays closed", complete: true}
      ]
    }
  ]
}
