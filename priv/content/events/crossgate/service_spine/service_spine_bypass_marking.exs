%Shunt.Events.Event{
  id: "crossgate_service_spine_bypass_marking",
  title: "Chalk Marking",

  on_complete: [{:knowledge, "crossgate_service_spine_bypass"}],

  steps: [
    %{
      id: "inspect",
      text: """
      A chalk mark on the service corridor wall — not graffiti, too
      deliberate for that. An arrow pointing toward a junction box,
      and beside it a rough shape that could be a gate with a line
      through it.
      """,
      choices: [
        %{label: "Follow the arrow", next: "follow"},
        %{label: "Ignore it"}
      ]
    },
    %{
      id: "follow",
      text: """
      Behind the junction box, a service crawlway runs parallel to
      the main tunnel — not on any map of The Crossgate, not wide
      enough for anything bulky, but more than enough for a person
      moving light. It surfaces at the far end of the transit tunnel,
      past the Tollgate.

      The mark wasn't made for you specifically. Someone made it for
      themselves, and didn't bother hiding it.
      """,
      choices: [
        %{label: "Note the route.", complete: true}
      ]
    }
  ]
}
