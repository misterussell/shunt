%Shunt.Events.Event{
  id: "shunt9_tally_task1",
  title: "Loose Paper",

  on_complete: [
    {:knowledge, "tally_task1"},
    {:npc_progression, "shunt9_tally", 1}
  ],

  steps: [
    %{
      id: "ask",
      text: """
      Tally's slate is open to a page she keeps half-covered with her forearm.
      "There's a stall three rows over — keeper's been trimming his own numbers
      before I ever see them, thinks I don't notice the shape of the hole." She
      doesn't look angry, just certain. "I don't send muscle. Muscle makes noise
      and noise costs more than the debt. I send someone who'll sit down, stay
      friendly, and let him talk himself into paying. You've got a face he hasn't
      learned to lie to yet."
      """,
      choices: [
        %{label: "What do I say to him?", next: "how"},
        %{label: "Sounds like your problem", next: "decline"}
      ]
    },
    %{
      id: "how",
      text: """
      "Nothing hard. Ask after his cousin, his takings, whether the worklights
      reached his row yet — and count the answers that don't line up." She slides
      the slate where you can see it: columns and columns, the whole platform
      rendered as who-owes-what. "Bring me what he leaves out, not what he says. I
      turn gossip into a number, and a number I can move. Do this for me a few
      times and I'll start finding you scrip in the margins the honest ledgers
      pretend aren't there."
      """,
      choices: [
        %{label: "I'll go listen", complete: true}
      ]
    },
    %{
      id: "decline",
      text: """
      "Suit yourself." She's already thumbing to the next page. "The debt keeps.
      They always do — that's the whole beauty of paper. Come back when you want a
      cut of it instead of just watching me collect."
      """,
      choices: [
        %{label: "Maybe later", complete: true}
      ]
    }
  ]
}
