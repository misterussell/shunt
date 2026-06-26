defmodule Shunt.WebTest do
  use ExUnit.Case, async: true

  # TODO: Author the minimal Juno reference content slice under priv/content/.
  # This is the copyable pattern for all future Web content, so keep it clean:
  #   - world_npc "juno" at location "shunt9_bazaar" with a SHORT linear
  #     story_arcs spine (2-3 events) — the arc is the existing npc_progression
  #     model, untouched.
  #   - one arc event whose on_complete grants {:modify_rep, "juno", :trust, N}.
  #   - one arc event whose on_complete grants {:knowledge, "juno_secret_supplier"}.
  #   - KNOWLEDGE reveal (rooks_desk-style gated LOCATION): a new location with
  #     location-level requirements: [{:knows, "juno_secret_supplier"}], reached
  #     by a new exit from the bazaar.
  #   - TRUST reveal (bazaar-style gated EXIT): a new exit whose requirements are
  #     [{:rep_at_least, "juno", :trust, N}].

  # TODO: Reveal behavior tests (context level; build players via plain structs).
  # Per project conventions do NOT assert exact counts/id-sets of content
  # collections — assert presence/absence of the specific gated id instead.
  #   - knowledge reveal: the gated location id is ABSENT from
  #     World.accessible_locations/1 and Movement.can_move?/2 to it is false when
  #     player.knowledge lacks "juno_secret_supplier"; both flip once it is added.
  #   - trust reveal: same absent-then-present pattern, gated on reputation trust
  #     reaching N via the player's reputation map.

  # TODO: New Web effect types in Shunt.Effects (can also live in effects_test.exs
  # when implemented): {:modify_rep, npc, dim, delta} updates the nested
  # reputation map clamped at 0; {:knowledge, key} / {:contact, key} append to the
  # respective list only when absent (idempotent).
end
