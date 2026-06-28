%Shunt.Events.Event{
  id: "grayline_glassline_through",
  title: "Clean Read",
  repeatable: false,

  requirements: [
    {:knows, "midgrid_echo"}
  ],

  steps: [
    %{
      id: "cross",
      text: """
      You walk a turnstile like you've done it a thousand times, because the echo
      says you have. The reader catches your record, finds three dull years of a
      life you never lived, and opens without a thought. No alarm. No second look.
      You're through — standing on the clean side, in the wide and certain
      Midgrid, indistinguishable from everyone the grid was built to wave along.
      """,
      choices: [
        %{label: "Look at what's ahead", next: "ahead"}
      ]
    },
    %{
      id: "ahead",
      text: """
      The concourse runs on past anything you can see from here, bright and
      orderly and deep. Somewhere in it is whatever you climbed for. But you've
      been awake a long time, you're wearing a name that's only hours old, and the
      far end of this floor is a problem for a shift that isn't this one. You came
      up. You got read clean. For now, that's the whole of the win — and it's not
      a small one.
      """,
      choices: [
        %{label: "You belong here now", complete: true}
      ]
    }
  ]
}
