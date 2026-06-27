%Shunt.Events.Event{
  id: "market_squeeze_partial",
  title: "Half the Picture",
  repeatable: true,

  on_complete: [],

  steps: [
    %{
      id: "incomplete",
      text: """
      Two of the threads touch, but the third won't sit. You can feel there's a
      single shape behind the spot-fees and the dried-up supply — you just can't
      name it yet. Somebody in the market is still holding the piece you're
      missing.
      """,
      choices: [
        %{label: "Keep listening", complete: true}
      ]
    }
  ]
}
