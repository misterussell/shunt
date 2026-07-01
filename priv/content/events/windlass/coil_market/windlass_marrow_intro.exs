%Shunt.Events.Event{
  id: "windlass_marrow_intro",
  title: "The Parcel He Carried",
  repeatable: false,

  on_complete: [
    {:rumor, "windlass_greased_report"}
  ],

  steps: [
    %{
      id: "skim",
      text: """
      Marrow talks low, the way people do when they've spent years being unheard.
      "You're the one poking at the engine. Word travels down here fast — we've got
      nothing to do but listen." He watches the market's back door. "I move parcels
      nobody wants a name on. Couple weeks back I carried one for the Authority. A
      sealed inspection report. On the engine."
      """,
      choices: [
        %{label: "So?", next: "before"}
      ]
    },
    %{
      id: "before",
      text: """
      "So I carried it three days before the inspector ever went near the engine."
      He lets you sit with that. "The failure was written before anyone looked.
      They decided what the engine did, then stalled it to match." His jaw works.
      "I'm on the purge list, friend. First name on it, probably. So I'll say what
      the permitted won't: they broke the machine to have a reason to clear us out.
      Prove that, and maybe fewer of us disappear. Prim, up in High Anchor — she
      saw the list. Ask her."
      """,
      choices: [
        %{label: "I'll find Prim", complete: true}
      ]
    }
  ]
}
