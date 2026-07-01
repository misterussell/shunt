%Shunt.Events.Event{
  id: "bloom_silas_foreclosure",
  title: "Coming Due",
  repeatable: false,
  requirements: [
    {:contact_known, "bloom_silas"}
  ],
  on_complete: [
    {:knowledge, "bloom_book_leveraged"}
  ],
  steps: [
    %{
      id: "call",
      text: """
      You watch Silas call a name in. No raised voice — just the forms, slid across
      the counter to a woman whose whole shine was borrowed, the sorry look, the
      quiet arithmetic. She'd been almost listed. Now she's almost nothing. "It's
      not cruelty," Silas tells you afterward, meaning it. "The Bloom runs on people
      spending what they don't have. I just keep the book." He straightens the
      forms. "And the book is getting heavy this season. A lot of names came due at
      once."
      """,
      choices: [
        %{label: "Ask how many", complete: true}
      ]
    }
  ]
}
