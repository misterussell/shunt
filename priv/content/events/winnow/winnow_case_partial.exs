%Shunt.Events.Event{
  id: "winnow_case_partial",
  title: "Most of the Shape",
  repeatable: false,
  requirements: [],
  on_complete: [
    {:scrip, 16}
  ],
  steps: [
    %{
      id: "gap",
      text: """
      You've got most of it — the climbing spoiled count, the scared wardens, the door
      nobody faces — and it clearly points past the Authority to something higher up the
      throat. But "clearly points" isn't proof, and the sealed door doesn't open on a
      hunch. There's a piece you don't have: the orders themselves, the quota in the act of
      coming down the channel, in a form the door will recognize as knowing. That runs
      through the line's own controller, behind the ICE on the Sorting Floor. You'll have to
      go in and take it before the case will carry your weight against that wall.
      """,
      choices: [
        %{label: "Find the missing piece", complete: true}
      ]
    }
  ]
}
