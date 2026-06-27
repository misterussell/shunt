%Shunt.Events.Event{
  id: "liftworks_clean_names_failure",
  title: "Read Wrong",
  repeatable: true,

  on_complete: [
    {:heat, 15}
  ],

  steps: [
    %{
      id: "burn",
      text: """
      The theory doesn't hold, and you pushed it somewhere it was noticed.
      Whoever is running the operation at the Watch Office has long practice
      seeing who's looking. You asked the wrong question in the wrong place.

      Your name is on a list you haven't seen. The duty roster changes the
      next morning.
      """,
      choices: [
        %{label: "Go quiet", complete: true}
      ]
    }
  ]
}
