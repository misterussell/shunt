%Shunt.Events.Event{
  id: "crossgate_register_cipher_intro",
  title: "Cipher",

  on_complete: [{:npc_progression, "crossgate_register_cipher", 1}],

  steps: [
    %{
      id: "cold",
      text: """
      The person behind the desk doesn't look up when you enter.
      They're reading something on a slate that goes dark the moment
      they register your presence.

      "You came through Hest." Still not looking up. "That means
      you're not a threat. It doesn't mean I know what you want."
      """,
      choices: [
        %{label: "Information. That's what you sell.", next: "direct"},
        %{label: "Someone pointed me here. I'm not sure why yet.", next: "honest"}
      ]
    },
    %{
      id: "direct",
      text: """
      Finally, they look up. Something in the directness registers
      as acceptable.

      "I broker information. I don't sell it retail — I work
      introduction by introduction, and I price by what knowing
      something is actually worth to the person asking." A pause.
      "Name's Cipher. Come back when you have a specific question
      and something to trade against it."
      """,
      choices: [
        %{label: "I'll be back.", complete: true}
      ]
    },
    %{
      id: "honest",
      text: """
      "Hest sends people here when they seem like they might
      eventually be worth knowing." The slate goes into a drawer.
      "Name's Cipher. I deal in information — specific questions,
      specific answers, priced accordingly. Come back when you
      know what you're looking for."
      """,
      choices: [
        %{label: "I will.", complete: true}
      ]
    }
  ]
}
