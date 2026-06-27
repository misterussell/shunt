defmodule Shunt.WebResolveTest do
  use ExUnit.Case, async: true

  alias Shunt.Players.Player
  alias Shunt.Web
  alias Shunt.Web.RumorConnection

  setup do
    conn = %RumorConnection{
      id: "test_connection",
      rumors: ["r1", "r2", "r3"],
      partial_threshold: 2,
      success_event_id: "success_evt",
      partial_event_id: "partial_evt",
      failure_event_id: "failure_evt"
    }

    :ets.insert(:rumor_connections, {conn.id, conn})
    on_exit(fn -> :ets.delete(:rumor_connections, conn.id) end)
    %{conn: conn}
  end

  describe "resolve_theory/2 - success" do
    test "returns {:success, event_id} when submitted rumors exactly match a connection" do
      player = %Player{rumors: ["r1", "r2", "r3"]}

      assert Web.resolve_theory(player, ["r1", "r2", "r3"]) == {:success, "success_evt"}
    end

    test "returns {:success, event_id} regardless of submission order" do
      player = %Player{rumors: ["r1", "r2", "r3"]}

      assert Web.resolve_theory(player, ["r3", "r1", "r2"]) == {:success, "success_evt"}
    end
  end

  describe "resolve_theory/2 - partial" do
    test "returns {:partial, event_id} when overlap meets partial_threshold but is incomplete" do
      player = %Player{rumors: ["r1", "r2"]}

      assert Web.resolve_theory(player, ["r1", "r2"]) == {:partial, "partial_evt"}
    end
  end

  describe "resolve_theory/2 - failure" do
    test "returns {:failure, event_id} when at least one rumor overlaps but is below partial_threshold" do
      player = %Player{rumors: ["r1"]}

      assert Web.resolve_theory(player, ["r1"]) == {:failure, "failure_evt"}
    end
  end

  describe "resolve_theory/2 - no match" do
    test "returns {:no_match, nil} when submitted rumors share no overlap with any connection" do
      player = %Player{rumors: ["unrelated"]}

      assert Web.resolve_theory(player, ["unrelated"]) == {:no_match, nil}
    end
  end
end
