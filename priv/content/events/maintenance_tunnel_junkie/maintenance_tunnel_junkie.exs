# TODO: split this single event into the Tunnel Junkie's story arc, per
# priv/docs/SHUNT_npc_architecture.md "Suggested Content Organization" +
# "Event-Driven Progression" sections. Once Shunt.Events.Event has on_complete and the
# {:npc_progression, npc_key, delta} effect exists:
#
#   priv/content/events/maintenance_tunnel_junkie/
#     intro.exs           - rename this file's content to id
#                            "shunt9_maintenance_tunnel_junkie_intro" (current steps below
#                            can stay as-is), add
#                            on_complete: [{:npc_progression, "shunt9_maintenance_tunnel_junkie", 1}]
#     parts_request.exs   - new event, id "shunt9_maintenance_tunnel_junkie_parts_request":
#                            junkie follows up on the "keep an eye out for parts" promise
#                            from intro, player reports back; on_complete advances
#                            progression by 1 same as above
#     stash_problem.exs   - new event, id "shunt9_maintenance_tunnel_junkie_stash_problem":
#                            junkie has a problem with their stash (something's missing or
#                            spoiled), player responds; on_complete advances progression
#                            by 1 same as above
#
# Delete this file once split. Each new file needs the rest of the steps/choices content
# (terse, noir tone, matching the existing step below) and a final `complete: true` choice.

%Shunt.Events.Event{
  id: "shunt9_maintenance_tunnel_junkie",
  title: "Tunnel Junkie",

  steps: [
    %{
      id: "inspect",
      text: """
      A figure crouches in the shadows, hunched over a pile of discarded tech.
      They look up as you approach, eyes strung out and curious.
      """,
      choices: [
        %{label: "Talk to them", next: "talk"},
        %{label: "Leave them alone"}
      ]
    },
    %{
      id: "talk",
      text: """
      "I've seen you digging around in the filth. You finding anything good?"
      """,
      choices: [
        %{label: "Nothing yet, just looking for parts. Trying to make some scrip.", next: "parts"}
      ]
    },
    %{
      id: "parts",
      text: """
      I'll keep an eye out for you.
      """,
      choices: [
        %{label: "Thanks."}
      ]
    }
  ]
}
