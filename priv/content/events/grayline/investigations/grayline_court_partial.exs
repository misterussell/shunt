%Shunt.Events.Event{
  id: "grayline_court_partial",
  title: "Half the Court",
  repeatable: false,

  on_complete: [
    {:knowledge, "cutaway_found"},
    {:scrip, 30}
  ],

  steps: [
    %{
      id: "partial",
      text: """
      You have pieces, not the picture. Enough to see the Court is more than a
      counter — templates kept somewhere back, a hand inside the registry, muscle
      down at the line — but not enough to lay it all out and make Quire flinch.
      What does come clear is one name on the edge of it: a burned ex-clerk
      working a gap behind the Tare, writing echoes off the Court's own books.
      """,
      choices: [
        %{label: "Follow that thread", next: "thread"}
      ]
    },
    %{
      id: "thread",
      text: """
      Cal. The Cutaway. You can't squeeze the Court with what you've got — but you
      can go around it. Sometimes the half you can use beats the whole you can't.
      """,
      choices: [
        %{label: "Note the way to the Cutaway", complete: true}
      ]
    }
  ]
}
