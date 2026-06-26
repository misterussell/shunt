defmodule Shunt.ContentIntegrityTest do
  use ExUnit.Case, async: true

  # TODO: implement the referential-integrity safety net for The Web gating (runs in
  # mix precommit). Scan all loaded content and assert:
  #   - every {:has_item, k} requirement referenced by any event has at least one event whose
  #     on_complete grants it via {:inventory, k, n} with n > 0;
  #   - every {:knows, k} requirement has some event granting {:knowledge, k};
  #   - every {:contact_known, k} requirement has some event granting {:contact, k};
  #   - every {:has_item, k} key exists in the :quest_items catalog.
  # This turns a typo'd item/knowledge key (which would otherwise silently soft-lock an errand)
  # into a failing test. Use presence-based assertions, not exact counts/id-sets.
  @tag :skip
  test "every gating key has a granting effect somewhere in content"
end
