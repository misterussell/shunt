%Shunt.Events.Event{
  id: "winnow_leda_intro",
  title: "The Count That Doesn't Sit Right",
  repeatable: false,
  requirements: [],
  on_complete: [
    {:contact, "winnow_leda"}
  ],
  steps: [
    %{
      id: "line",
      text: """
      She waves you over with a reseating tool, low, so the bench boss won't clock it. "You've
      got new eyes, so tell me if I'm mad. I strip chrome off the culled all day. Good chrome.
      Ports, shunts, grafts barely worn." She sets a piece down between you: sleek, recent,
      nothing a throat-come intake could ever afford. "Nobody comes up from below wearing this.
      So where's it coming from? It's coming down the belt on people who had it *installed* —
      up there, close, somewhere in the Spire that puts good chrome in a body and then sends
      the body here to be stripped." She holds your eye. "I've been counting a month. Once you
      start counting you can't stop. And once you can't stop, you stop being useful to them."
      """,
      choices: [
        %{label: "Tell her she's not mad", complete: true}
      ]
    }
  ]
}
