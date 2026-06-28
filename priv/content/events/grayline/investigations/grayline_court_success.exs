%Shunt.Events.Event{
  id: "grayline_court_success",
  title: "Court of Hollow Names",
  repeatable: false,

  on_complete: [
    {:knowledge, "court_leverage"},
    {:knowledge, "cutaway_found"},
    {:scrip, 120}
  ],

  steps: [
    %{
      id: "whole",
      text: """
      The threads pull tight and the whole Court stands clear. The templates
      racked in the Stacks. Sana's borrowed registry access, run off a clerk
      uptown who doesn't know he's lending it. Reyes at the Holdover, making sure
      the only people the Watch catches are the ones who skipped the counter. And
      under all of it, Proxy at the Liftworks, feeding flagged arrivals up the
      pipeline to be made real at a price. It isn't a gang. It's an institution
      that the grid forgot to authorize.
      """,
      choices: [
        %{label: "What's it worth?", next: "leverage"}
      ]
    },
    %{
      id: "leverage",
      text: """
      Worth this: you know where every seam in the Court is, which means you know
      exactly what Quire stands to lose. That's a lever long enough to pull an
      echo out of her with nothing in your hand but what you've learned. And the
      same map names Cal — the burned clerk in the Cutaway who'll teach you to do
      it yourself. The Court only had power while it was the only one who
      understood it. Now that's two of you.
      """,
      choices: [
        %{label: "Decide how to spend it", complete: true}
      ]
    }
  ]
}
