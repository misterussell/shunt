%Shunt.Events.Event{
  id: "crossgate_register_cipher_old_debt",
  title: "Cipher",

  on_complete: [{:npc_progression, "crossgate_register_cipher", 1}],

  steps: [
    %{
      id: "waiting",
      text: """
      Cipher is already watching the door when you arrive, like
      they knew you were coming — which, you realize, they probably
      did.

      "I have something for you. Not something you asked for —
      something that fell into my hands and has your name on it,
      loosely." They set a sealed data chip on the desk. "Midgrid
      origin. Someone was running a background check on a runner
      matching your description and operating profile. The report
      was never delivered."
      """,
      choices: [
        %{label: "Who commissioned it?", next: "who"},
        %{label: "Who intercepted it?", next: "how"}
      ]
    },
    %{
      id: "who",
      text: """
      "Unknown. The commission was routed through three cutouts."
      Cipher slides the chip forward. "Which means either someone
      very professional or someone who learned professional habits
      from someone else." A pause. "The interesting part is that
      the report was paid for but never picked up. Either the buyer
      found out what they needed another way, or they're gone."
      """,
      choices: [
        %{label: "I'll take the chip.", complete: true},
        %{label: "What do you want for it?", next: "price"}
      ]
    },
    %{
      id: "how",
      text: """
      "I have a contact at the routing node." Cipher says nothing
      more about that. "The chip has the report. Whatever's in it
      is yours to know." They push it across the desk. "Consider
      it an introduction to what I can do. Future items will have
      a price attached."
      """,
      choices: [
        %{label: "Fair enough.", complete: true}
      ]
    },
    %{
      id: "price",
      text: """
      "Nothing, this time. Consider it a demonstration." They lean
      back. "You'll want to work with me again after you read
      what's on it. That's the price — future business."
      """,
      choices: [
        %{label: "Take the chip.", complete: true}
      ]
    }
  ]
}
