%Shunt.Events.Event{
  id: "windlass_hex_intro",
  title: "Out of the Wires",
  repeatable: false,

  steps: [
    %{
      id: "open",
      text: """
      You've not seen her before, which is the point. "Hex," she says, working a
      deck in plain sight at a bench that had a reader over it last time you passed.
      "You don't know me because until this week there was nowhere safe to stand and
      be known. That's changed. Enough readers are dark now that the Collective can
      breathe on this floor." She nods at the dead lens on the wall. "That's your
      doing. Drift doesn't say thank you, so I will."
      """,
      choices: [
        %{label: "It's not finished", next: "core"}
      ]
    },
    %{
      id: "core",
      text: """
      "No. Contested isn't open — the Authority still owns the trunk." She lowers her
      voice, though for once she doesn't have to. "There's a grid core under the
      Coldroom. Crack that and every reader in the Windlass goes dark at once, top to
      bottom. It's the meanest ICE in the district and it'll cost you. But finish
      what you started here and the Collective doesn't just breathe — it wins." She
      goes back to her deck. "When you're ready for it, you'll know where I stand."
      """,
      choices: [
        %{label: "I'll remember", complete: true}
      ]
    }
  ]
}
