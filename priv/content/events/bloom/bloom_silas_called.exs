%Shunt.Events.Event{
  id: "bloom_silas_called",
  title: "The Book Called",
  repeatable: false,
  requirements: [
    {:knows, "bloom_book_leveraged"}
  ],
  on_complete: [
    {:knowledge, "bloom_book_called"}
  ],
  steps: [
    %{
      id: "dark",
      text: """
      The book comes down all at once. Silas calls the season's debts together and
      the Bloom goes dark petal by petal — the Reclaim's racks stripped, a Gilt Row
      frontage shuttered overnight, whole rooms that glowed last week standing cold.
      The Closed Hands own it all on paper now, and paper doesn't keep the lights
      on. "This is the part nobody performs," Silas says, watching a sign die. "The
      shine was always mortgaged. Somebody was always going to call it." He almost
      sounds sorry. He signs the next form anyway.
      """,
      choices: [
        %{label: "Watch the lights go out", complete: true}
      ]
    }
  ]
}
