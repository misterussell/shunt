%Shunt.Events.Event{
  id: "grayline_quire_make_you_someone",
  title: "Make You Someone",
  repeatable: false,

  requirements: [
    {:knows, "court_known"}
  ],

  on_complete: [
    {:scrip, -250},
    {:knowledge, "midgrid_echo"},
    {:npc_loyalty, "grayline_quire", 5}
  ],

  steps: [
    %{
      id: "deal",
      text: """
      "Scrip, then." Quire names a number that is most of what you have and says
      it the way she'd read a docket. "It buys the whole of it — Sana writes you
      into the registry, the templates seat your history, the readers stop seeing
      a hole where a person should be. No installments. The Court doesn't carry
      anyone. That's why the Court is still here."
      """,
      choices: [
        %{label: "Pay it", next: "written"},
        %{label: "Not at that price"}
      ]
    },
    %{
      id: "written",
      text: """
      The scrip leaves your hand and Quire is already at the terminal, Sana at
      the next one matching template to record like a seamstress matching thread.
      It takes less time than you expected. "Done," Quire says. "You were no one
      this morning. You're a Midgrid resident of three years' standing now, with
      a dull job and a clean ledger. Try to live like it. The clean ones never
      get looked at twice."
      """,
      choices: [
        %{label: "You're someone now", complete: true}
      ]
    }
  ]
}
