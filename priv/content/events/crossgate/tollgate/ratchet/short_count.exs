%Shunt.Events.Event{
  id: "crossgate_tollgate_ratchet_short_count",
  title: "Ratchet",

  on_complete: [
    {:npc_progression, "crossgate_tollgate_ratchet", 1},
    {:knowledge, "crossgate_house_entry_granted"}
  ],

  steps: [
    %{
      id: "trouble",
      text: """
      Ratchet's running the count early — a ledger out, entries
      cross-checked against the toll log. They look up when you
      approach, but not to stop you this time.

      "You move around The Crossgate more than most. You notice
      anything running through here that doesn't pass through my
      booth?"
      """,
      choices: [
        %{label: "The Service Spine bypasses the Tollgate.", next: "spine"},
        %{label: "I haven't been looking.", next: "not_looking"}
      ]
    },
    %{
      id: "spine",
      text: """
      A flat look. "I know about the Spine. Someone's been using it
      to move volume — not the usual foot traffic, actual product.
      The count's been short for three weeks." They close the ledger.
      "That's Syndicate scrip going somewhere it shouldn't."

      A longer look at you. "Strand needs to know. I'd take it
      myself but I can't leave the gate. You look like someone who
      can walk into the House without it being unusual." They write
      something on a slip and hand it over. "Show that at the door."
      """,
      choices: [
        %{label: "I'll take it to Strand.", complete: true}
      ]
    },
    %{
      id: "not_looking",
      text: """
      "Start looking." No heat in it — a statement. "The count's
      short and I need to know why before the Syndicate asks me
      why." A pause. "Come back if you find something."
      """,
      choices: [
        %{label: "I'll keep an eye out.", complete: true}
      ]
    }
  ]
}
