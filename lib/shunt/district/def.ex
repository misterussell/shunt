defmodule Shunt.District.Def do
  @moduledoc """
  Static definition of a district's derived world-state facts. Authored as `.exs`
  content under priv/content/districts and loaded by Shunt.Content.Store (the generic
  load_source/2 handles it via `.id`).

  `facts` maps a fact name (atom) to a derivation rule. Slice 1 supports one rule kind:

    * `:ordinal` — `%{kind: :ordinal, levels: [..ascending..], default: level,
      rules: [{level, requirements}, ...]}`. The first rule (top-down) whose requirements
      are met (via Shunt.Requirements) yields that level; otherwise `default`. The rules'
      requirements use the existing requirement DSL, so a fact derives purely from
      already-persisted player state (player.infrastructure, player.knowledge, ...) — no
      new persistence.

  The `:count` rule kind (a fact whose value is the number of satisfied condition-sets,
  for population/commerce) is a documented, non-breaking extension to add when that
  content lands — not built speculatively in slice 1.
  """

  @enforce_keys [:id, :name, :facts]
  defstruct [:id, :name, :facts]
end
