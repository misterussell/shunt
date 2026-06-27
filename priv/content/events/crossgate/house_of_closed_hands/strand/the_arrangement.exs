%Shunt.Events.Event{
  id: "crossgate_house_strand_the_arrangement",
  title: "Strand",

  on_complete: [{:npc_progression, "crossgate_house_strand", 1}],

  steps: [
    %{
      id: "offer",
      text: """
      Strand is reading something when you arrive — doesn't look
      up immediately. When they do, there's a decision already made
      in their expression.

      "The runner using the Spine has been identified. The matter
      is handled." A pause that implies what 'handled' means. "That
      is not why I wanted to see you."

      They push a folded document across the table. "The Syndicate
      does not recruit casually. We offer arrangements. This is
      yours, if you want it."
      """,
      choices: [
        %{label: "What does the arrangement involve?", next: "details"},
        %{label: "I work alone.", next: "alone"}
      ]
    },
    %{
      id: "details",
      text: """
      "You move through the Underbelly already. You have contacts
      in Shunt 9. You have a working deck." Strand's tone is the
      same discussing you as it would be discussing inventory.
      "The Syndicate needs eyes in places that don't know they're
      being watched. You would be compensated. You would be
      protected. You would owe us — which in The Crossgate means
      something."

      They wait.
      """,
      choices: [
        %{label: "I'll think about it.", complete: true},
        %{label: "I'm in.", complete: true}
      ]
    },
    %{
      id: "alone",
      text: """
      "Nobody in the Underbelly works alone. They just haven't
      found out yet who they're working for." Strand folds the
      document away. "The offer stays open. Come back when the
      answer changes."
      """,
      choices: [
        %{label: "I'll come back.", complete: true}
      ]
    }
  ]
}
