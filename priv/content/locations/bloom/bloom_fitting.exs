alias Shunt.World.Exit

%{
  id: "bloom_fitting",
  name: "The Fitting",
  short_description:
    "A tailor of performed wealth; a suit here is a costume for a part you haven't got.",
  description:
    "The last room on Gilt Row, where a tailor cuts you into the shape of someone who belongs. The cloth is reclaimed insulation, dressed and dyed until it passes. Everything in the Bloom is a costume; here they just admit it.",
  tags: [:midgrid, :market],
  graph_position: {3560, -2120},

  # TODO: flavor-only — no core wiring required. Optional vendor (a cosmetic cred/scrip sink) and
  # a tailor NPC for colour. Deepens the shop petal and reinforces the "performed wealth" theme.
  npcs: [],
  events: [],
  exits: [
    %Exit{id: "fitting_to_gloss", to: "bloom_gloss"}
  ]
}
