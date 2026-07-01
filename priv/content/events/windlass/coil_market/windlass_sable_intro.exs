%Shunt.Events.Event{
  id: "windlass_sable_intro",
  title: "Who's Short",
  repeatable: false,

  on_complete: [
    {:rumor, "windlass_spire_certification"}
  ],

  steps: [
    %{
      id: "booth",
      text: """
      Sable doesn't look up from her paper. "You're not here to buy and you're not
      here to borrow, so you're here for the other thing." She sets the pen down.
      "Information's the Ledger's real stock. I know who's short in this district,
      and lately everybody's short, because the freight stopped and the Authority's
      in a hurry. You want to know why they're in a hurry?"
      """,
      choices: [
        %{label: "Tell me", next: "cert"}
      ]
    },
    %{
      id: "cert",
      text: """
      "The Windlass is being certified — brought onto the Spire's supply chain.
      Big money, if the district passes." She lets that hang. "Certification means
      the count comes out clean. And a district's count is only dirty in one way:
      too many people the grid can't read. Do the arithmetic on what 'clean' means
      when you're one of the numbers." She picks the pen back up. "The Syndicate
      doesn't take sides. But we do like to know who's going to win. Come back when
      you've got something to trade."
      """,
      choices: [
        %{label: "I'll remember the Ledger", complete: true}
      ]
    }
  ]
}
