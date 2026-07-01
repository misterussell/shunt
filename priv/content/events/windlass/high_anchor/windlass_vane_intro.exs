%Shunt.Events.Event{
  id: "windlass_vane_intro",
  title: "The Kindness of Order",
  repeatable: false,

  steps: [
    %{
      id: "desk",
      text: """
      Inspector Vane rises when you enter, which is somehow worse than if he hadn't.
      "You've been busy down the coil. Slagworks, the Fitworks, the market — you do
      get around." His smile is genuine, which is the frightening part. "I run the
      way up out of the Windlass. I'd like us to be friends, because friends of the
      Ascent Office find the climb so much easier than the alternative."
      """,
      choices: [
        %{label: "And the alternative?", next: "offer"}
      ]
    },
    %{
      id: "offer",
      text: """
      "The alternative is you keep pulling threads until something unravels that
      can't be re-woven, and then I have to be sad about it." He spreads his hands.
      "The freight will run again when it's certified safe. The district will be
      certified once the count is in order. Everyone who belongs here will be fine.
      Stop digging, take a permit when it's offered, and go up clean. Order is a
      kindness, friend. I'd hate to have to be unkind." He sits. "Think it over.
      The gate isn't going anywhere. Neither, for now, are you."
      """,
      choices: [
        %{label: "I'll think it over", complete: true}
      ]
    }
  ]
}
