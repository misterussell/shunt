%Shunt.Events.Event{
  id: "winnow_roan_smuggle",
  title: "Padding the Count",
  repeatable: false,
  requirements: [
    {:contact_known, "winnow_roan"}
  ],
  on_complete: [
    {:knowledge, "winnow_quota_bought"},
    {:scrip, 30}
  ],
  steps: [
    %{
      id: "pad",
      text: """
      "You want the culls to stop, you don't fight the number," Roan says, laying it out
      on a galley crate. "You feed it. There's spoiled stock the wire won't take and
      nobody's counting close — reclaimed shunts, half-filed intake sitting in the Keep
      backlog. We dress it, we log it, we make the count without putting a single warm body
      on the belt to make up the gap." He taps the forged tally. "Wardens hit their number,
      they don't go looking for the difference. Nobody gets culled for arithmetic that
      already balances." He slides you your cut. "It's a lie that keeps people off the wire.
      Cleanest kind there is. Won't last forever — but it buys the caste room to breathe,
      and it buys us time to do something realer."
      """,
      choices: [
        %{label: "Forge the tally", complete: true}
      ]
    }
  ]
}
