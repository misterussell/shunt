%Shunt.Events.Event{
  id: "grayline_court_failure",
  title: "Asking Loud",
  repeatable: false,

  on_complete: [
    {:heat, 8}
  ],

  steps: [
    %{
      id: "wrong",
      text: """
      You pulled the threads in the wrong order and the wrong ears heard the
      pulling. Nothing you gathered holds together — and worse, it gathered
      attention back. A stall goes quiet when you pass it now. Reyes knows your
      face that didn't know it last shift. The Court isn't worried. The Court is
      simply aware of you, which in the Grayline is its own kind of debt.
      """,
      choices: [
        %{label: "Let it cool", complete: true}
      ]
    }
  ]
}
