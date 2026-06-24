defmodule Shunt.Events.Event do
  @moduledoc false

  @enforce_keys [:id, :title, :steps]
  defstruct [:id, :title, :description, :steps]

  # TODO: add `on_complete: []` to the defstruct list above (non-enforced, default empty
  # list), per priv/docs/SHUNT_npc_architecture.md "Event-Driven Progression" section.
end
