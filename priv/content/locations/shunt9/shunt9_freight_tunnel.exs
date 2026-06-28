alias Shunt.World.Exit

%{
  id: "shunt9_freight_tunnel",
  name: "Freight Tunnel",

  short_description:
    "An old freight tunnel listed as decommissioned. The lights still work.",

  description:
    "Long enough that both ends disappear into the dark. The ceiling is low and riveted, original transit infrastructure from before the platform above it was built over. Coolant lines still hum along one wall. Crates sit in a staging alcove near the far end, tagged in a shorthand that doesn't match any public manifest.",

  tags: [
    :infrastructure,
    :underbelly,
    :restricted
  ],

  graph_position: {550, 570},

  requirements: [
    {:contact_known, "dex_broker"}
  ],

  # TODO: add an `events:` list wiring the two new freight-tunnel events below, mirroring
  # how shunt9_maintenance_tunnel.exs exposes its `events:`. The tunnel is reachable via
  # supplier_conspiracy_success (discovers it + grants the dex_broker contact + the
  # "freight_tunnel_shipments" rumor) but currently holds zero content. Both events are the
  # Web-skill payoff for that finished investigation — acting on Vex's debts (the contractor
  # signing ghost manifests) and Dex (the broker). Effect vocabulary is limited to
  # :scrip/:heat/:inventory/:knowledge/:rumor/:contact — there is NO :rep or faction effect
  # for events. Do not spawn a new dangling rumor (that would recreate the orphan we are
  # fixing); the ongoing thread IS the repeatable skim. Prose must follow docs/SHUNT_*.
  #
  #   events: [
  #     "shunt9_freight_tunnel_ghost_route",
  #     "shunt9_freight_tunnel_skim"
  #   ],
  #
  # TODO: create priv/content/events/shunt9/freight_tunnel/ghost_route.exs as a
  # %Shunt.Events.Event{} (id: "shunt9_freight_tunnel_ghost_route", repeatable: false) — the
  # one-shot leverage confrontation at the staging alcove (crates tagged in shorthand that
  # doesn't match any manifest). The player presses Vex's debts and cashes out, learning the
  # route well enough to skim it afterward. on_complete: [{:scrip, <one-shot payoff>},
  # {:heat, <risk cost>}, {:knowledge, "freight_route_worked"}]. Note on_complete is
  # event-level (events.ex:68), applied the same for every `complete: true` choice, so narrate
  # any squeeze-vs-quiet framing as branching steps that converge on the same payoff; include
  # a no-`complete` "leave it" choice that exits without consuming the event (see
  # maintenance_tunnel/relay_stash.exs "Leave it").
  #
  # TODO: create priv/content/events/shunt9/freight_tunnel/skim.exs as a
  # %Shunt.Events.Event{} (id: "shunt9_freight_tunnel_skim", repeatable: true,
  # requirements: [{:knows, "freight_route_worked"}]) — the low, ongoing income beat: skim a
  # single shipment for modest scrip at low heat. on_complete: [{:scrip, <small>}, {:heat,
  # <low>}]. Gated on the knowledge token granted by ghost_route so it only opens after the
  # one-shot confrontation. Mirror the repeatable pattern in juno/odd_job_deliver.exs.

  exits: [
    %Exit{
      id: "freight_tunnel_to_maintenance_tunnel",
      to: "shunt9_maintenance_tunnel"
    }
  ]
}
