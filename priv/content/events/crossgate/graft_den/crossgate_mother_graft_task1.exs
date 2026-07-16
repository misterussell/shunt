%Shunt.Events.Event{
  id: "crossgate_mother_graft_task1",
  title: "Clean Cut",

  on_complete: [
    {:knowledge, "mother_graft_task1"},
    {:npc_progression, "crossgate_mother_graft", 1}
  ],

  steps: [
    %{
      id: "ask",
      text: """
      There's a man on the pallet table who won't stop shaking. "A grafter three
      levels down put weave in him and didn't seat it right. Now it's fighting the
      meat." Mother Graft doesn't sound angry, only inconvenienced. "The Fleshless
      don't leave botched work walking around telling people what we do. I need
      someone to walk him back down and make sure the fitter never seats another."
      """,
      choices: [
        %{label: "What do you need from me?", next: "what"},
        %{label: "That's not my work", next: "decline"}
      ]
    },
    %{
      id: "what",
      text: """
      "Take him down, point him at the fitter, and stand there while he says his
      piece. No hands, no heat — just a face from the Den that the fitter knows to
      fear." She threads a fresh line. "You do that quiet, and word gets around
      that my people don't get touched. That's worth a cleaner rate to me. Less
      trace on your sales, more scrip in your pocket."
      """,
      choices: [
        %{label: "I'll walk him down", complete: true}
      ]
    },
    %{
      id: "decline",
      text: """
      "Squeamish." She says it like a diagnosis, not an insult. "Fine. He'll
      shake it off or he won't. The offer keeps — the Fleshless are patient about
      who they let close."
      """,
      choices: [
        %{label: "Maybe later", complete: true}
      ]
    }
  ]
}
