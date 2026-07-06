# Windlass Ghostwork gear pilot — the tier deck. This is the ENTIRE slot progression past the
# starter jury_rigged_terminal (3 slots): Axis 1 turns on the moment this loads, because
# Shunt.Ghostwork.active_deck/1 already picks the highest-`slots` deck owned and deck_slots/1 already
# sizes the loadout from it. Four slots relieves the 5-keys-in-3-slots squeeze by one — a felt gain.
#
# Vault-ONLY: the only source is windlass_anchor_vault's forge_vault subroutine reward. No vendor.
#
# TODO: finalize `name` + `text` against docs/SHUNT_LEXICON.md (Collective/Fitworks-built deck voice).
%{
  id: "fitworks_deck",
  name: "Fitworks Deck",
  slots: 4,
  text:
    "Collective-cut and clean-socketed — four sockets that actually seat true. The Fitworks only builds one when the grid war has already been won."
}
