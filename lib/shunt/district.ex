defmodule Shunt.District do
  @moduledoc """
  Derived district world-state. A pure read-side over existing player state: facts are
  computed on demand from priv/content/districts defs via Shunt.Requirements, never
  persisted. Repairs (and other facts) are the single source of truth; district facts
  cannot drift from them.
  """

  alias Shunt.Content

  def get!(id), do: Content.fetch!(:districts, id)

  # TODO: implement fact/3 — fact(player, district_id, fact_name) returns the derived value
  # of an :ordinal fact. Fetch the def via get!/1, read the rule at def.facts[fact_name],
  # and return the `level` of the first {level, requirements} entry in rule.rules (top-down)
  # whose requirements pass Shunt.Requirements.met?/2; otherwise return rule.default.

  # TODO: implement fact_meets?/5 — fact_meets?(player, district_id, fact_name, op, target)
  # for op in [:>=, :<]. Derive the current ordinal level (reuse fact/3's logic), then compare
  # current vs target by their index in the fact rule's :levels list (ascending), so
  # :online >= :partial is true and :partial < :online is true. This is what the
  # {:district, district_id, fact, op, target} requirement delegates to.

  # TODO: author priv/content/districts/shunt9.exs — a %Shunt.District.Def{} with id "shunt9",
  # name "Shunt 9", and one fact:
  #   power: %{
  #     kind: :ordinal,
  #     levels: [:offline, :partial, :online],
  #     default: :offline,
  #     rules: [
  #       {:online,  [{:infra_state, "shunt9_power_relay_generator", "repaired"}]},
  #       {:partial, [{:infra_state, "shunt9_power_relay_generator", "patched"}]}
  #     ]
  #   }
end
