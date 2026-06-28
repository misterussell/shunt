defmodule ShuntWeb.Components.MapGraphTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest
  use Phoenix.Component

  alias Shunt.World.Exit
  alias ShuntWeb.Components.MapGraph

  @player %{location_id: "a", discovered_locations: ["a", "b", "e"]}

  @locations [
    %{id: "a", name: "Alpha", graph_position: {0, 0}, exits: [%Exit{to: "b"}, %Exit{to: "c"}]},
    %{id: "b", name: "Bravo", graph_position: {100, 0}, exits: [%Exit{to: "a"}]},
    %{id: "c", name: "Charlie", graph_position: {0, 100}, exits: [%Exit{to: "a"}]},
    %{id: "d", name: "Delta", graph_position: {100, 100}, exits: []},
    %{id: "e", name: "Echo", graph_position: {200, 200}, exits: []}
  ]

  defp render_map(assigns) do
    render_component(&map_graph_wrapper/1, assigns)
  end

  defp map_graph_wrapper(assigns) do
    ~H"""
    <MapGraph.map_graph player={@player} locations={@locations} />
    """
  end

  test "the current location renders as a filled node with no move handler" do
    html = render_map(%{player: @player, locations: @locations})

    assert html =~ "Alpha"
    refute html =~ ~s(id="move-to-a")
  end

  test "a directly-connected, never-visited location renders bright and clickable" do
    html = render_map(%{player: @player, locations: @locations})

    assert html =~ ~s(id="move-to-c")
    assert html =~ ~s(phx-click="move_to")
    assert html =~ "Charlie"
  end

  test "a directly-connected, already-discovered location is still clickable" do
    html = render_map(%{player: @player, locations: @locations})

    assert html =~ ~s(id="move-to-b")
  end

  test "a location with no exit from current renders its real name but is not clickable" do
    html = render_map(%{player: @player, locations: @locations})

    assert html =~ "Echo"
    refute html =~ ~s(id="move-to-e")
  end

  test "an undiscovered, unreachable location renders redacted and is not clickable" do
    html = render_map(%{player: @player, locations: @locations})

    assert html =~ "???"
    refute html =~ "Delta"
    refute html =~ ~s(id="move-to-d")
  end

  defp legend_wrapper(assigns) do
    ~H"""
    <MapGraph.map_legend />
    """
  end

  test "the viewBox is a fixed window size regardless of world bounds" do
    html = render_map(%{player: @player, locations: @locations})

    assert html =~ ~s(viewBox="0 0 640 440")
  end

  test "the viewBox stays the same fixed size even with far-apart locations" do
    far_locations = [
      %{id: "a", name: "Alpha", graph_position: {0, 0}, exits: []},
      %{id: "z", name: "Zulu", graph_position: {5000, 5000}, exits: []}
    ]

    player = %{location_id: "a", discovered_locations: ["a"]}
    html = render_map(%{player: player, locations: far_locations})

    assert html =~ ~s(viewBox="0 0 640 440")
  end

  test "the world group is centered on the current location and scaled to frame its neighbors" do
    player = %{location_id: "b", discovered_locations: ["a", "b"]}
    html = render_map(%{player: player, locations: @locations})

    # "b" at {100,0}, only connected neighbor "a" at {0,0} fits, so scale stays 1.0.
    assert html =~ ~s{transform="translate(320, 220) scale(1.0) translate(-100, 0)"}
  end

  test "the world group zooms out so a far connected neighbor stays inside the window" do
    far_locations = [
      %{id: "a", name: "Alpha", graph_position: {900, 230}, exits: [%Exit{to: "z"}]},
      %{id: "z", name: "Zulu", graph_position: {1350, 230}, exits: [%Exit{to: "a"}]}
    ]

    player = %{location_id: "a", discovered_locations: ["a"]}
    html = render_map(%{player: player, locations: far_locations})

    scale = Float.round(280 / 450, 4)
    assert html =~ ~s{transform="translate(320, 220) scale(#{scale}) translate(-900, -230)"}
  end

  test "fit_scale stays at 1.0 when every connected neighbor fits the window" do
    assert MapGraph.fit_scale({0, 0}, [{100, 0}, {0, 100}]) == 1.0
  end

  test "fit_scale stays at 1.0 when there are no connected neighbors" do
    assert MapGraph.fit_scale({0, 0}, []) == 1.0
  end

  test "fit_scale zooms out so a horizontally distant neighbor stays inside the window" do
    # concourse {900,230} -> intake_hall {1350,230}: dx=450, hx = 320 - 40 = 280.
    assert_in_delta MapGraph.fit_scale({900, 230}, [{1350, 230}]), 280 / 450, 0.0001
  end

  test "fit_scale zooms out so a vertically distant neighbor stays inside the window" do
    # concourse {900,230} -> house_of_closed_hands {900,530}: dy=300, hy = 220 - 40 = 180.
    assert_in_delta MapGraph.fit_scale({900, 230}, [{900, 530}]), 180 / 300, 0.0001
  end

  test "map_legend/1 renders all four legend rows" do
    html = render_component(&legend_wrapper/1, %{})

    assert html =~ "CURRENT LOCATION"
    assert html =~ "CONNECTED"
    assert html =~ "DISCOVERED"
    assert html =~ "UNDISCOVERED"
  end
end
