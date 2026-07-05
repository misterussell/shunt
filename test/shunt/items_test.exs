defmodule Shunt.ItemsTest do
  use ExUnit.Case, async: true

  alias Shunt.Items

  test "resolves display name for a raw item" do
    assert Items.display_name("battered_relay_coil") == "Battered Relay Coil"
  end

  test "resolves display name for a quest item" do
    assert Items.display_name("juno_parcel") == "Wrapped Parcel"
  end

  test "resolves display name for a chrome raw (event-granted salvage)" do
    assert Items.display_name("salvaged_servo") == "Salvaged Servo"
  end

  test "resolves display name for an implant (NPC-granted augment)" do
    assert Items.display_name("lineman_graft") == "Lineman's Graft"
  end

  test "raises for an unknown key" do
    assert_raise RuntimeError, ~r/unknown item/, fn ->
      Items.display_name("nonexistent_key")
    end
  end
end
