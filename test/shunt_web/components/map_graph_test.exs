defmodule ShuntWeb.Components.MapGraphTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest
  use Phoenix.Component

  alias Shunt.World.Exit
  alias ShuntWeb.Components.MapGraph

  @player %{location_id: "a", discovered_locations: ["a", "b", "e"]}

  @locations [
    %{key: "a", name: "Alpha", graph_position: {0, 0}, exits: [%Exit{to: "b"}, %Exit{to: "c"}]},
    %{key: "b", name: "Bravo", graph_position: {100, 0}, exits: [%Exit{to: "a"}]},
    %{key: "c", name: "Charlie", graph_position: {0, 100}, exits: [%Exit{to: "a"}]},
    %{key: "d", name: "Delta", graph_position: {100, 100}, exits: []},
    %{key: "e", name: "Echo", graph_position: {200, 200}, exits: []}
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

  test "map_legend/1 renders all four legend rows" do
    html = render_component(&legend_wrapper/1, %{})

    assert html =~ "CURRENT LOCATION"
    assert html =~ "CONNECTED"
    assert html =~ "DISCOVERED"
    assert html =~ "UNDISCOVERED"
  end
end
