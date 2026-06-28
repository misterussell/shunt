%Shunt.Events.Event{
  id: "grayline_reyes_pressure",
  title: "The Collector",
  repeatable: false,

  on_complete: [
    {:rumor, "bailiff_collects"},
    {:heat, 5}
  ],

  steps: [
    %{
      id: "noticed",
      text: """
      A man leans against the Holdover desk like he owns the lease — Reyes, who
      the Court calls the Bailiff and the Watch calls a problem they've decided
      not to have. He watches the cells the way a landlord watches a leak. "New,"
      he says. "I can tell. New ones look at the holding like it's for someone
      else."
      """,
      choices: [
        %{label: "Who ends up in there?", next: "who"}
      ]
    },
    %{
      id: "who",
      text: """
      "People who tried to skip the counter." He says it pleasantly. "Forge your
      own echo, buy off some independent, slip the line on a homemade name — grid
      catches it eventually, and when it does, the Watch sets you down here, and
      I make sure you stay set down. Court likes its toll paid. I'm how it gets
      paid by the ones who'd rather not." He smiles. "Pay the counter. Cheaper
      than meeting me twice."
      """,
      choices: [
        %{label: "Step back out", complete: true}
      ]
    }
  ]
}
