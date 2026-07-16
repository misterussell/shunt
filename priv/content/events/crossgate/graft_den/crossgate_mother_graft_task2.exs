%Shunt.Events.Event{
  id: "crossgate_mother_graft_task2",
  title: "Fleshless Favor",

  on_complete: [
    {:knowledge, "mother_graft_task2"},
    {:npc_progression, "crossgate_mother_graft", 1}
  ],

  steps: [
    %{
      id: "open",
      text: """
      The table's empty for once. She's counting a tray of subdermal wire into
      sorted rows — surgical stock, the kind the Fleshless run up from below. "The
      fitter's done. My people walk the lower levels without flinching now, and
      the stock still moves." She sets the tray down. "That was your quiet. I don't
      forget who kept it quiet."
      """,
      choices: [
        %{label: "So what changes?", next: "change"},
        %{label: "Why bring me this far in?", next: "why"}
      ]
    },
    %{
      id: "change",
      text: """
      "You sell at the Fleshless rate now. Top scrip, and it moves so cold the
      wire never learns it happened." She slides a row of stock into a case. "Same
      salvage you were always bringing me — I just stop pretending you're a
      stranger and start pricing you like family. Keep bringing it. We're always
      one part short of whole."
      """,
      choices: [
        %{label: "Understood", complete: true}
      ]
    },
    %{
      id: "why",
      text: """
      "Because flesh is a rough draft, and so is trust — you keep revising until
      it holds." A thin, clinical smile. "You handled a body of ours like it
      mattered and didn't ask what it was for. That's rarer than good salvage.
      The Fleshless keep what's rare."
      """,
      choices: [
        %{label: "I'll keep bringing it", complete: true}
      ]
    }
  ]
}
