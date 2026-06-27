%Shunt.Events.Event{
  id: "shunt9_food_stalls_ladle_gossip",
  title: "Over the Pot",

  on_complete: [
    {:npc_progression, "shunt9_food_stalls_ladle", 1},
    {:rumor, "cook_supply_short"}
  ],

  steps: [
    %{
      id: "lean",
      text: """
      Ladle waves you closer with the ladle itself, lowering her voice under the
      clatter of the row. "Since you've got an ear. Something's gone wrong with
      supply. Protein, oil — the stuff I can't cook without. The runners who
      brought it in at a fair rate have dried up. Gone quiet, or gone somewhere
      that pays them better to stay quiet."
      """,
      choices: [
        %{label: "Who'd squeeze a food row?", next: "who"},
        %{label: "Bad luck happens", next: "luck"}
      ]
    },
    %{
      id: "who",
      text: """
      "That's the part that itches." She stirs hard, like the pot offended her.
      "Loudest complainers are the ones who can't get a thing now. Like somebody's
      listening for who grumbles and turning off their tap. That's not bad luck.
      That's a hand on the valve." She straightens. "You hear the rest of it out
      there, you bring it back to me. I'll know what it means."
      """,
      choices: [
        %{label: "Count on it", complete: true}
      ]
    },
    %{
      id: "luck",
      text: """
      "Bad luck doesn't pick the same stalls every week." She gives you a flat
      look over the steam. "But sure. Bad luck. You keep your ears open anyway —
      and if you turn up why my oil costs double, you bring it to me first."
      """,
      choices: [
        %{label: "If I hear anything", complete: true}
      ]
    }
  ]
}
