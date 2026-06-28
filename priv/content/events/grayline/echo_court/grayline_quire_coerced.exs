%Shunt.Events.Event{
  id: "grayline_quire_coerced",
  title: "What the Court Owes",
  repeatable: false,

  requirements: [
    {:knows, "court_leverage"}
  ],

  on_complete: [
    {:knowledge, "midgrid_echo"},
    {:heat, 8},
    {:npc_loyalty, "grayline_quire", -20}
  ],

  steps: [
    %{
      id: "lay_it_out",
      text: """
      You take a number you don't need and, when it comes up, you lay it on the
      counter instead of scrip: the templates racked in the Stacks, the registry
      access Sana shouldn't have, the names the Court has been writing in and the
      Watch the Court has been paying to look past. All of it. Mapped. "An echo,"
      you say. "On the house."
      """,
      choices: [
        %{label: "Hold her eyes", next: "concede"}
      ]
    },
    %{
      id: "concede",
      text: """
      Quire's clerk-calm doesn't break, but it costs her something to hold it.
      "You understand this is a once," she says, typing. "You're written in.
      You're also remembered now, by me, which is the most expensive thing in the
      Grayline." The echo seats. "Go to the line before I reconsider what
      remembering you is worth. And don't take a number here again."
      """,
      choices: [
        %{label: "Take the echo and go", complete: true}
      ]
    }
  ]
}
