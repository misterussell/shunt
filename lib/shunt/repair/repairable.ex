defmodule Shunt.Repair.Repairable do
  @moduledoc """
  A persistent, repairable piece of Underbelly infrastructure (a generator, lift,
  purifier, etc). Authored as `.exs` content under priv/content/repairables and loaded
  by Shunt.Content.Store. Repair *state* lives on the player (player.infrastructure);
  this struct is the static definition.

  Fields:
    * `inspect_tiers` — ordered list of `%{requirements: [...], text: "..."}`. The deepest
      tier whose requirements are met (via Shunt.Requirements) is the diagnosis shown.
      Tiers are gated on existing signals (tool ownership / knowledge), not undesigned
      Street Alchemy tiers.
    * `solutions` — list of `%{id, label, from: [state,...], requirements: [...],
      consumes: %{item_key => qty}, result_state, effects: [...], outcome_text}`.
      `requirements` are checked but NOT consumed (tools); `consumes` are spent.
    * `state_descriptions` — `%{state => description}` overlaid on the location's base
      description by Shunt.World.effective_description/2 when the object is in that state.
  """

  @enforce_keys [:id, :name, :location_id, :initial_state, :inspect_tiers, :solutions]
  defstruct [
    :id,
    :name,
    :location_id,
    :initial_state,
    :inspect_tiers,
    :solutions,
    state_descriptions: %{}
  ]
end
