%Shunt.Events.Event{
  id: "grayline_cal_intro",
  title: "Make Your Own",
  repeatable: false,

  on_complete: [
    {:knowledge, "echo_forge_method"}
  ],

  steps: [
    %{
      id: "bench",
      text: """
      Cal doesn't look up from the bench when you find the Cutaway. Burn scars on
      the forearms, a Court clerk's posture gone feral. "Word travels," they say.
      "You found the gap behind the Tare, so somebody told you I write echoes
      Quire doesn't get a cut of. True. I used to write them for her. Then I
      learned how the seam actually opens, and a thing you can open yourself isn't
      worth paying for."
      """,
      choices: [
        %{label: "Show me the seam", next: "teach"},
        %{label: "Why help me?", next: "teach2"}
      ]
    },
    %{
      id: "teach",
      text: """
      "It's not a forgery you carry in — it's an edit you make from the inside."
      Cal sketches it fast: the registry node lives in the Stacks, current-spec on
      the face and soft in the back, and it'll take a write if you feed it a stub
      shaped like the Court's own templates. "Build the stub. Get to the node.
      Open it clean and the grid writes you in by its own hand." A flat look.
      "Open it dirty and Reyes meets you at the line. Your risk, not mine. That's
      the whole difference between me and the Court."
      """,
      choices: [
        %{label: "I'll build it", complete: true}
      ]
    },
    %{
      id: "teach2",
      text: """
      Cal finally looks up. "Because every echo Quire doesn't sell is a brick out
      of her wall. I'm not generous. I'm patient." They go back to the bench.
      "Build a stub that reads like a Court template. Take it to the registry node
      in the Stacks. Open the seam yourself. After that you don't owe the counter
      a thing — you owe the heat, same as anyone who skips a toll."
      """,
      choices: [
        %{label: "I'll build it", complete: true}
      ]
    }
  ]
}
