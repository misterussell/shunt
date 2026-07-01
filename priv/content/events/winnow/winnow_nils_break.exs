%Shunt.Events.Event{
  id: "winnow_nils_break",
  title: "The Warden Who Wouldn't",
  repeatable: false,
  requirements: [
    {:contact_known, "winnow_nils"},
    {:district, "winnow", :quota, :>=, :culling}
  ],
  on_complete: [
    {:npc_loyalty, "winnow_nils", 1},
    {:rumor, "winnow_wardens_afraid"}
  ],
  steps: [
    %{
      id: "log",
      text: """
      The number's impossible and Nils has to log the belt list — the names that make up
      the gap. You find him in the booth not doing it, the stylus down, his hand flat on the
      glass. "I've written this list a hundred times," he says. "Told myself the door made me.
      That I'm just the hand." He doesn't look up. "You've been up here stirring things. So
      let me be a hand for you instead, this once." He turns the log toward you — who's
      slated, who could be quietly missed, which readers he can claim jammed. "I can lose a
      name or two in the paperwork. Not many. Not without ending up on the belt myself. But
      I'm done pretending the door does the culling. The door writes a number. Men like me
      turn it into people." It's not courage yet. It's the shape courage leaves.
      """,
      choices: [
        %{label: "Take what he'll give", complete: true}
      ]
    }
  ]
}
