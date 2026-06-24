defmodule Shunt.Events do
  @moduledoc false

  alias Shunt.Content

  # TODO: fetch a Shunt.Events.Event by id from the :events ETS table, mirroring
  # Shunt.Skills.Catalog.fetch!/1:
  #   def get!(id), do: Content.fetch!(:events, id)

  # TODO: return all loaded events, mirroring Shunt.World.all_locations/0:
  #   def all, do: Content.all(:events)

  # TODO: resolve the step a player should see for a given event_id:
  #   - if player.event_state[event_id]["current_step"] is set, look up that step in
  #     get!(event_id).steps (raise if the id is missing — same fail-fast convention as
  #     Content.fetch!/2)
  #   - otherwise return the event's first step (List.first(event.steps))
  #   def current_step(player, event_id)

  # TODO: dispatch-resolver for starting an event (called via
  # Players.dispatch(player_id, &Events.start(&1, event_id)), same pattern as
  # Shunt.Movement.move/2). Sets event_state for event_id to its first step's id via the
  # existing generic {:set, :event_state, new_map} Effects clause (effects.ex:72) — no new
  # Effects code needed. Returns {:ok, effects, meta}.
  #   def start(player, event_id)

  # TODO: dispatch-resolver for submitting a choice
  # (Players.dispatch(player_id, &Events.choose(&1, event_id, choice_label))). Must:
  #   - look up the player's own recorded current_step (via current_step/2) — never trust a
  #     client-submitted step, same defensive style as Movement.can_move?/2
  #   - find the matching choice by label on that step; return {:error, :invalid_choice} if
  #     not found
  #   - if the choice (or the step it leads to) is terminal (complete: true): set
  #     completed_events to [event_id | player.completed_events] (dedup) and remove event_id
  #     from event_state, both via {:set, field, value} effects
  #   - otherwise: advance event_state's current_step to the choice's :next step id
  #   - if the event_id is already in player.completed_events, return
  #     {:error, :already_completed} rather than re-running the above
  #   def choose(player, event_id, choice_label)
end
