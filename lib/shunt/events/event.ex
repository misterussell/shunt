defmodule Shunt.Events.Event do
  @moduledoc false

  # TODO: define the struct per priv/docs/SHUNT_event_system.md's "Event Data Structure" and
  # "Event Step Model" sections, with these deliberate departures from the doc (agreed during
  # design): no :repeatable? or :requirements fields — both are explicitly out of MVP scope.
  #
  #   @enforce_keys [:id, :title, :steps]
  #   defstruct [:id, :title, :description, :steps]
  #
  # Each entry in :steps is a plain map (not a nested struct, consistent with how locations'
  # :exits and other nested content shapes are kept as plain maps in this codebase):
  #   %{
  #     id: "inspect",
  #     text: "...",
  #     choices: [
  #       %{label: "Examine circuitry", next: "circuitry"},
  #       %{label: "Leave it alone", complete: true}
  #     ]
  #   }
  #   %{
  #     id: "circuitry",
  #     text: "...",
  #     rewards: [{:knowledge, :ghostwork}],  # inert data — nothing reads :rewards yet
  #     complete: true
  #   }
end
