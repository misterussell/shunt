%Shunt.Events.Event{
  id: "shunt9_tally_task2",
  title: "Cooked Books",

  on_complete: [
    {:knowledge, "tally_task2"},
    {:npc_progression, "shunt9_tally", 1}
  ],

  steps: [
    %{
      id: "open",
      text: """
      Tally's got two slates going now — the one she shows the Syndicate and the
      one that tells the truth, and she's stopped hiding the second one from you.
      "You've listened for me all over this platform. Turns out you're better at
      it than half my regulars, and a good deal quieter." She flips the true slate
      around. "So here's what nobody gets to have: I'm going to start writing your
      line the way I'd write my own."
      """,
      choices: [
        %{label: "Meaning what?", next: "how"},
        %{label: "Why me?", next: "why"}
      ]
    },
    %{
      id: "how",
      text: """
      "Meaning your debts settle at a number I decide, and the number's kind. A
      fee gets logged late, a cut gets rounded the friendly way, a marker you
      bring me buys back more than it ever should." She taps both slates, one then
      the other. "The Syndicate reads the top book and sees nothing wrong. You
      read the bottom one and see scrip. That's the whole trick — cook it slow,
      cook it quiet, and nobody upstairs ever tastes it."
      """,
      choices: [
        %{label: "Cook it, then", complete: true}
      ]
    },
    %{
      id: "why",
      text: """
      "Because a ledger's only worth what the names on it are worth, and you've
      made yours worth keeping." She caps her pen. "The Closed Hands think debt is
      the leash. I know better — debt's just the favor you haven't called yet.
      You've done me enough of them. Now I do you one that pays every time you come
      by."
      """,
      choices: [
        %{label: "I'll be around", complete: true}
      ]
    }
  ]
}
