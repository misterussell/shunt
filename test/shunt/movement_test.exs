defmodule Shunt.MovementTest do
  use ExUnit.Case, async: true

  # TODO: write tests for Shunt.Movement, mirroring the shape of
  # test/shunt/players_test.exs's "lay_low/1" describe block (plain %Player{}
  # structs, no DB):
  #
  #   describe "can_move?/2" — true when player.location_id has a real exit to
  #     destination (e.g. from "shunt9_bazaar" to "shunt9_scrap_yard"); false
  #     when there is no exit between them.
  #
  #   describe "move/2" — for a connected destination, returns
  #     {:ok, [{:set, :location_id, destination}, {:discover_location, destination}], %{narrative: text}}
  #     where text is a non-empty string; for an unconnected destination, returns
  #     {:error, :not_connected}.
end
