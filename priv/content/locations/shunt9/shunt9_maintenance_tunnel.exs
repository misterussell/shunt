alias Shunt.World.Exit

%{
  key: "shunt9_maintenance_tunnel",
  name: "Maintenance Tunnel",

  short_description:
    "A narrow service tunnel running under the platform.",

  description:
    "Pipes and conduit lines run along the low ceiling, dripping condensation onto a walkway that hasn't seen an official inspection in years.",

  tags: [
    :infrastructure,
    :underbelly
  ],

  graph_position: {550, 400},

  # TODO: replace this `events:` entry with `npcs: ["shunt9_maintenance_tunnel_junkie"]`
  # once Shunt.World.NPC content + Content.Store's :world_npcs loader clause exist (see
  # TODOs in lib/shunt/world/npc.ex and lib/shunt/content/store.ex). The event then becomes
  # reachable via Shunt.World.Npcs.current_event/2 instead of being listed here directly.
  events: [
    "shunt9_maintenance_tunnel_junkie"
  ],

  exits: [
    %Exit{to: "shunt9_burned_platform"},
    %Exit{to: "shunt9_player_squat"}
  ]
}
