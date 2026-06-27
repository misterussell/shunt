%Shunt.Events.Event{
  id: "crossgate_graft_den_stitch_supply_shortage",
  title: "Stitch",

  on_complete: [{:npc_progression, "crossgate_graft_den_stitch", 1}],

  steps: [
    %{
      id: "problem",
      text: """
      Stitch is at the workbench but not working — just sitting,
      which doesn't fit the usual picture. When you come in, they
      turn without preamble.

      "Subdermal wiring. I'm out, and I have three procedures
      scheduled this week." A flat statement of fact. "The
      Fleshless usually handle my supply but they've gone dark.
      No contact, no delivery, no explanation."
      """,
      choices: [
        %{label: "The Fleshless? What's their connection to your supply chain?", next: "fleshless"},
        %{label: "I can look for an alternate source.", next: "source"}
      ]
    },
    %{
      id: "fleshless",
      text: """
      "They move augment material through channels the Syndicate
      doesn't touch. Good quality, consistent supply, no questions
      about end use." Stitch crosses their arms. "Whatever they're
      doing, it's pulled them off every supply arrangement they
      had running. Something happened."
      """,
      choices: [
        %{label: "I'll see if I can find out what.", next: "find_out"},
        %{label: "I'll find you an alternate source.", next: "source"}
      ]
    },
    %{
      id: "find_out",
      text: """
      "Information is useful, but I need wiring first." They hand
      you a written spec. "This is what I need. Bring me the
      material or bring me a reason the Fleshless have gone dark.
      Either moves the situation forward."
      """,
      choices: [
        %{label: "I'll start looking.", complete: true}
      ]
    },
    %{
      id: "source",
      text: """
      "Subdermal spec, not consumer grade." They pull out a
      written list. "This is what I need. If you can source it,
      I'll pay at the rate I paid the Fleshless — which was
      above market, because reliability is worth paying for."
      """,
      choices: [
        %{label: "I'll find it.", complete: true}
      ]
    }
  ]
}
