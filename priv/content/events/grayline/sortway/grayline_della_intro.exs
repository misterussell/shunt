%Shunt.Events.Event{
  id: "grayline_della_intro",
  title: "Welcome to the Tare",
  repeatable: false,

  on_complete: [
    {:rumor, "feeder_pipeline"}
  ],

  steps: [
    %{
      id: "read",
      text: """
      The woman who walked you in is Della. She's a hollow herself — been one so
      long she's stopped trying not to be. "You'll want the Tare," she says,
      nodding down the corridor. "Market, beds, all of it. And you'll want to
      know the shape of the place before it knows the shape of you."
      """,
      choices: [
        %{label: "What's the shape?", next: "shape"}
      ]
    },
    %{
      id: "shape",
      text: """
      "Grid won't read you. That's the whole problem and the whole business."
      She thumbs back toward the lift. "People come up flagged — Proxy moves a
      lot of them, down at the Liftworks, hands them off clean. Then up here the
      Echo Court makes them real, for a price, on their terms. Proxy's the
      pipeline. The Court's the toll." A shrug. "Or you find another way. People
      do."
      """,
      choices: [
        %{label: "Noted", complete: true}
      ]
    }
  ]
}
