defmodule Shunt.Ghostwork.WindlassGearPilotTest do
  @moduledoc """
  Windlass Ghostwork gear pilot — behavioral spec (STAGED as TODOs).

  Turns on the loadout choice (5 keys > 3 slots), the tier deck (Axis 1), and the
  crack->loot->crack economy, entirely as ice_authority content — no engine code.

  Implement each TODO below via superpowers:test-driven-development: write the test, watch it
  fail, then author the node layers / wire the lattice lead that makes it pass. Remove the TODO
  once its test is green.
  """
  use ExUnit.Case, async: true

  # --- The structural fix: key-space > slots -------------------------------------------------
  # TODO: "ice_authority now demands 5 distinct keys" — Ghostwork.family_coverage(player,
  #   "ice_authority") lists :spoof, :decrypt, :backdoor, :overload and :cloak once the three new
  #   nodes' layers are authored (the new keys ride windlass_slagfoot_relay / _skim_registry /
  #   _anchor_vault).
  # TODO: "the loadout choice bites" — for a jury_rigged_terminal holder, Ghostwork.deck_slots is 3,
  #   which is < the 5 keys ice_authority demands, so NO baseline loadout can cover every key
  #   (assert the count relationship, not a fixed id-set).
  # TODO: "family_coverage maps a key to an owned+matching program" — a player owning "dampener"
  #   (:cloak) sees its name against the :cloak key; nil when unowned.

  # --- The gear itself -----------------------------------------------------------------------
  # TODO: "the four new programs load well-formed" — Programs.fetch! for powerspike / arc_driver
  #   (:overload) and dampener / nullsleeve (:cloak) return progress > 0 and an on_weakness map.
  # TODO: "the tier deck loads at 4 slots" — Decks.fetch!("fitworks_deck").slots == 4, and for a
  #   holder Ghostwork.active_deck/deck_slots return 4 (relieving the squeeze by one slot).
  # TODO: "equip respects the active deck's slots" — with fitworks_deck owned, Ghostwork.equip lets a
  #   4th program in and rejects a 5th; with only jury_rigged_terminal, the 4th is rejected.

  # --- The mastery long-tail (Node 3 gate) ---------------------------------------------------
  # TODO: "Node 3 hidden below mastery 6" — Ghostwork.nodes_at excludes "windlass_anchor_vault" when
  #   ghostwork_state mastery["ice_authority"] < 6 (even holding windlass_anchor_vault_found), and
  #   includes it at >= 6.

  # --- The capstone loot (crack -> loot -> crack) --------------------------------------------
  # TODO: "the vault drops the tier deck" — in a windlass_anchor_vault encounter, hitting forge_vault
  #   with its matching key resolves effects containing {:inventory, "fitworks_deck", 1} (and
  #   arc_driver); a MISMATCHED hit on the vault returns status :locked_out and drops nothing.
  # TODO: "Node 2 loot" — clearing windlass_skim_registry's watch_ring layer dispatches
  #   {:inventory, "nullsleeve", 1}, and resolving that reward does NOT raise (guards the item-name
  #   path: GhostworkLive grants node rewards silently, never through Items.display_name — so
  #   decks/programs need no @item_tables entry; assert this stays true).

  # --- The threat showcase -------------------------------------------------------------------
  # TODO: "Node 2 is a bleed race" — windlass_skim_registry has a layer with >= 3 live :sentry
  #   subroutines keyed :cloak, so @sentry_bleed stacks and cloak's near-zero Trace is the answer.
  # TODO: "Node 3 forces both new keys" — windlass_anchor_vault's wardens layer carries a :cloak
  #   sentry AND an :overload trap on the same board.
end
