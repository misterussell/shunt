defmodule Shunt.Web.RumorConnectionTest do
  use ExUnit.Case, async: true

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
end
