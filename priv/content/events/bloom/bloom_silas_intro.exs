%Shunt.Events.Event{
  id: "bloom_silas_intro",
  title: "The Paper",
  repeatable: false,
  requirements: [],
  on_complete: [
    {:contact, "bloom_silas"}
  ],
  steps: [
    %{
      id: "counter",
      text: """
      Silas doesn't sell you anything. He just makes it easy — a line of credit, a
      quiet arrangement, everything the Bloom expects you to wear already on your
      back before you've earned a coin of it. "Nobody up here pays outright," he
      says, gentle as a man reading a will. "That isn't how it's done. You look the
      part, the part opens doors, the doors pay it back. Or they don't." He smiles,
      and it's a kind smile, and that's somehow the worst of it. "Either way, I keep
      the paper."
      """,
      choices: [
        %{label: "Sign", complete: true}
      ]
    }
  ]
}
