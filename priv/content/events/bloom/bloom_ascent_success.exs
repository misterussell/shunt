%Shunt.Events.Event{
  id: "bloom_ascent_success",
  title: "What Ascent Is",
  repeatable: false,
  requirements: [],
  on_complete: [
    {:knowledge, "bloom_ascent_clearance"}
  ],
  steps: [
    %{
      id: "case",
      text: """
      Laid side by side, the rumors stop being gossip and start being a shape. The
      vanishing. The bought names. The last fitting. The seam under every listed
      jaw. The friend who was gone before he went up. It all points one way: nobody
      up the throat is chosen for glory. They're selected, groomed, fitted, and
      sold — ascent is a harvest wearing a dream's face, and the whole clawing
      district is the pen. You know too much now to be nobody. A name like that
      gets noticed. Word comes back down almost at once: you're cleared. The throat
      will open for you. Come up whenever you're ready.
      """,
      choices: [
        %{label: "Take the clearance", complete: true}
      ]
    }
  ]
}
