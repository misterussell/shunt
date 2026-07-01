%Shunt.Events.Event{
  id: "windlass_sabotage_partial",
  title: "Close, Not Closed",
  repeatable: true,

  steps: [
    %{
      id: "lead",
      text: """
      The threads almost meet. A killed engine, a starved Collective, a certification
      with a body count, a purge list dated too early — it all points one direction,
      but pointing isn't proof. What you're missing is the thing with a signature on
      it: the order itself. That won't come from anyone willing to talk. It's sitting
      in the Authority's own permit registry, behind the scan arch in the Ascent
      Office, waiting for someone with the nerve to go in after it.
      """,
      choices: [
        %{label: "The registry, then", complete: true}
      ]
    }
  ]
}
