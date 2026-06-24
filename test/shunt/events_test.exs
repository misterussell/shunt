defmodule Shunt.EventsTest do
  use ExUnit.Case, async: true

  # TODO: implement against Shunt.Events once lib/shunt/events.ex's TODOs are resolved,
  # mirroring the style of test/shunt/movement_test.exs (plain %Player{} structs, no DB).
  # Cover at least:
  #   - get!/1 returns the event for a known id, raises for an unknown id
  #   - current_step/2 returns the first step for a player with no event_state entry
  #   - current_step/2 returns the recorded step when event_state has a current_step
  #   - start/2 returns {:set, :event_state, ...} effects pointing at the event's first step
  #   - choose/3 with a valid non-terminal choice advances event_state's current_step
  #   - choose/3 with a valid terminal choice sets completed_events and clears event_state
  #     for that event_id
  #   - choose/3 with a choice label not on the current step returns {:error, :invalid_choice}
  #   - choose/3 for an event already in player.completed_events returns
  #     {:error, :already_completed}
end
