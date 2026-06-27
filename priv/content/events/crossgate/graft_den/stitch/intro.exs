%Shunt.Events.Event{
  id: "crossgate_graft_den_stitch_intro",
  title: "Stitch",

  on_complete: [{:npc_progression, "crossgate_graft_den_stitch", 1}],

  steps: [
    %{
      id: "working",
      text: """
      A figure in a stained surgical apron is calibrating something
      small and precise under a magnifying lamp. They don't pause
      when you come in, but they note you.

      "Not bleeding, so you're not here for emergency work."
      They set down the tool. "First visit. You came from the
      Concourse, not the Pit." A look. "What are you shopping
      for?"
      """,
      choices: [
        %{label: "Just learning what's available.", next: "browse"},
        %{label: "I have a neural port that needs repair.", next: "port"}
      ]
    },
    %{
      id: "browse",
      text: """
      "Smart. Know your options before you need them." They wipe
      their hands. "Name's Stitch. I do installation, removal,
      calibration, and diagnosis. I don't do cosmetic work — not
      because I can't, because it's boring." A gesture at the
      operating table. "Everything here is functional."
      """,
      choices: [
        %{label: "Good to know.", complete: true}
      ]
    },
    %{
      id: "port",
      text: """
      Interest, professional and immediate. "Show me." They pull
      the magnifying lamp over and examine the port without
      touching it yet. "Burned, not cracked. The housing can be
      salvaged." They sit back. "I can work with this. I'll need
      specific components — I'll write down what, and where to
      find them. Name's Stitch."
      """,
      choices: [
        %{label: "Write up the list.", complete: true}
      ]
    }
  ]
}
