alias Shunt.World.Exit

%{
  id: "bloom_gloss",
  name: "The Gloss",
  short_description:
    "The gloss parlor — cosmetic chrome to make you look like you belong up the throat.",
  description:
    "A clean, bright room that fits you with the finish of the ascended: a subdermal sheen, a steadier voice, a face that reads as listed. Everyone leaves looking a little more like they've already made it. Nobody asks what the fitting actually installs.",
  tags: [:midgrid, :market],
  graph_position: {3440, -2260},

  # TODO — the Chrome & Meat hook, implemented on knowledge flags (no body-state engine yet):
  #   - A parlor event whose on_complete grants "bloom_glossed" (the "you got glossed" flag).
  #   - Gate some social access on {:knows, "bloom_glossed"} (an inner room / an NPC).
  #   - The pocket-of-C reveal: a later event gated on {:knows,"bloom_glossed"} + :season>=:churning,
  #     revealing the gloss is the neural shunt that makes you Latticework-ready (ties the believed
  #     meat-cover and the substrate-truth together at the clinic).
  # ANCHOR FOR LATER: when the Chrome & Meat skill / body-state storage is built, wire real
  # augments in here — the fiction (the gloss is already a neural shunt) is the seam to hang them on.
  npcs: [],
  events: [],
  exits: [
    %Exit{id: "gloss_to_gilt_row", to: "bloom_gilt_row"},
    %Exit{id: "gloss_to_fitting", to: "bloom_fitting"}
  ]
}
