defmodule Shunt.Web.RumorConnectionTest do
  # Not async: mutates the shared global :rumor_connections ETS table (same as web_live_test).
  use ExUnit.Case

  alias Shunt.Web.RumorConnection

  setup do
    conn = %RumorConnection{
      id: "test_connection",
      rumors: ["r1", "r2", "r3"],
      partial_threshold: 2,
      success_event_id: "success_evt",
      partial_event_id: "partial_evt",
      failure_event_id: "failure_evt",
      lead_heat: 2,
      crack_heat: 5
    }

    :ets.insert(:rumor_connections, {conn.id, conn})
    on_exit(fn -> :ets.delete(:rumor_connections, conn.id) end)
    %{conn: conn}
  end

  describe "fetch!/1" do
    test "returns the %RumorConnection{} for a known id", %{conn: conn} do
      assert RumorConnection.fetch!("test_connection") == conn
    end

    test "raises for an unknown id" do
      assert_raise RuntimeError, fn -> RumorConnection.fetch!("no_such_connection") end
    end
  end

  describe "all/0" do
    test "includes loaded connections", %{conn: conn} do
      assert conn in RumorConnection.all()
    end
  end

  describe "heat costs" do
    test "every authored connection has integer lead_heat and crack_heat" do
      for conn <- RumorConnection.all() do
        assert is_integer(conn.lead_heat), "#{conn.id} is missing an integer lead_heat"
        assert is_integer(conn.crack_heat), "#{conn.id} is missing an integer crack_heat"
      end
    end

    test "cracking a case costs more heat than following its lead" do
      for conn <- RumorConnection.all() do
        assert conn.crack_heat > conn.lead_heat,
               "#{conn.id}: crack_heat (#{conn.crack_heat}) should exceed lead_heat (#{conn.lead_heat})"
      end
    end
  end
end
