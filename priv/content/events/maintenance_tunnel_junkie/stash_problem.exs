%Shunt.Events.Event{
  id: "shunt9_maintenance_tunnel_junkie_stash_problem",
  title: "Tunnel Junkie",

  on_complete: [{:npc_progression, "shunt9_maintenance_tunnel_junkie", 1}],

  steps: [
    %{
      id: "trouble",
      text: """
      The junkie's stash is gone, just a torn-open panel where it used to sit.
      "Someone's been through here. Wasn't you, right?"
      """,
      choices: [
        %{label: "Wasn't me. Who else has access down here?", next: "lead"}
      ]
    },
    %{
      id: "lead",
      text: """
      "Couple of scrap runners use this tunnel as a shortcut. Wouldn't put it
      past them." They shake their head. "Doesn't matter now. It's gone."
      """,
      choices: [
        %{label: "I'll keep an eye out for it.", complete: true}
      ]
    }
  ]
}
