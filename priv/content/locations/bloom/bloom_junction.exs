alias Shunt.World.Exit

%{
  id: "bloom_junction",
  name: "The Junction",
  short_description: "A repurposed duct-junction with a view — a foothold you can make your own.",
  description:
    "Where three ducts meet behind the compete petal, someone's walled off a room: warm off the bleed, lit off the runoff, quiet off the Authority's map. A junction in the flower, and about the best address in the Midgrid a person like you could ever hold.",
  tags: [:midgrid, :hideout, :infrastructure],
  graph_position: {3080, -1710},

  # Tier-6 "Junction" premises (class 3) — home for the Bleed Tap + Skim Crew income modules.
  premises_class: 3,
  # TODO: finalize relocation cost (cred-heavy — this is the luxury tier; guess below) and any
  # requirements to move in (e.g. an investigation/standing flag). Confirm against the Winder's
  # Loft (windlass) relocation block as the reference.
  relocation: %{
    cost: %{scrip: 800, cred: 100},
    requirements: []
  },

  # TODO: discovery gating — how the player finds/earns the Junction (an event granting
  # {:discover_location, "bloom_junction"} and/or a knowledge flag). Optional atmosphere on :draw
  # (the room brightens/warms as the Spire pulls).
  npcs: [],
  events: [],
  exits: [
    %Exit{id: "junction_to_vent_run", to: "bloom_vent_run"}
  ]
}
