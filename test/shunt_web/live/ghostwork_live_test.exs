defmodule ShuntWeb.GhostworkLiveTest do
  use ShuntWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Shunt.Ghostwork.IceNode
  alias Shunt.Players

  setup do
    Players.create_player!()
    player_id = Players.get_player!().id

    location = %{
      id: "gw_test_loc",
      name: "Relay Vault",
      description: "A dead-frequency relay.",
      lattice: %{
        leads: [
          %{
            id: "relay_lead",
            requirements: [],
            text: "a maintenance relay on a dead frequency",
            on_intercept: [{:knowledge, "gw_node_found"}]
          }
        ],
        filler: [%{weight: 1, text: "stray feed fragments", on_intercept: [{:scrip, 1}]}]
      }
    }

    node = %IceNode{
      id: "gw_test_node",
      name: "Abandoned Relay",
      family: "ice_maintenance",
      location_id: "gw_test_loc",
      requirements: [{:knows, "gw_node_found"}],
      cool_threshold: 60,
      layers: [
        %{
          id: "l1",
          name: "Handshake",
          progress_required: 6,
          trace_multiplier: 1.0,
          weakness: nil,
          reward: [{:knowledge, "gw_node_cracked"}]
        }
      ]
    }

    :ets.insert(:locations, {location.id, location})
    :ets.insert(:ice_nodes, {node.id, node})

    on_exit(fn ->
      :ets.delete(:locations, "gw_test_loc")
      :ets.delete(:ice_nodes, "gw_test_node")
    end)

    # Hold a deck and jack in from the relay-vault location.
    Players.dispatch(player_id, fn _player ->
      {:ok, [{:inventory, "jury_rigged_terminal", 1}, {:set, :location_id, "gw_test_loc"}], %{}}
    end)

    %{player_id: player_id}
  end

  test "the deck page renders scan and a tier-1 earned title", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/skills/ghostwork")

    assert has_element?(view, "#scan-button")
    assert has_element?(view, "#loadout-empty")
    assert has_element?(view, "#title-1.title-row--earned")
  end

  test "the deck tether names the jacked-in location", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/skills/ghostwork")

    assert has_element?(view, "#deck-tether", "Relay Vault")
  end

  test "the lattice carrier is live and bursts on a successful scan", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/skills/ghostwork")

    assert has_element?(view, "#lattice-carrier")
    refute has_element?(view, "#lattice-carrier.lattice-carrier--flat")

    view |> element("#scan-button") |> render_click()

    assert_push_event(view, "lattice:pulse", %{})
  end

  test "the carrier flatlines where there is no lattice traffic", %{conn: conn, player_id: pid} do
    :ets.insert(
      :locations,
      {"gw_dead_loc", %{id: "gw_dead_loc", name: "Dead Air", description: "Silence."}}
    )

    on_exit(fn -> :ets.delete(:locations, "gw_dead_loc") end)
    Players.dispatch(pid, fn _player -> {:ok, [{:set, :location_id, "gw_dead_loc"}], %{}} end)

    {:ok, view, _html} = live(conn, ~p"/skills/ghostwork")
    view |> element("#scan-button") |> render_click()

    assert has_element?(view, "#lattice-carrier.lattice-carrier--flat")
  end

  test "a node stays hidden until a scan reveals it", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/skills/ghostwork")

    refute has_element?(view, "#break-gw_test_node")

    view |> element("#scan-button") |> render_click()

    assert has_element?(view, "#signal-feed", "maintenance relay on a dead frequency")
    assert has_element?(view, "#break-gw_test_node")
  end

  test "a revealed node shows its read status, dark before any mastery", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/skills/ghostwork")
    view |> element("#scan-button") |> render_click()

    assert has_element?(view, "#node-read-gw_test_node.ghostwork-node-read--dark")
  end

  test "breaking a node opens the ICE terminal", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/skills/ghostwork")
    view |> element("#scan-button") |> render_click()

    view |> element("#break-gw_test_node") |> render_click()

    assert has_element?(view, "#ice-modal")
    assert has_element?(view, "#ice-probe")
  end

  test "probing through the layer cracks the node and closes the terminal", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/skills/ghostwork")
    view |> element("#scan-button") |> render_click()
    view |> element("#break-gw_test_node") |> render_click()

    # progress_required 6, probe +3 each: two probes crack the single layer.
    view |> element("#ice-probe") |> render_click()
    view |> element("#ice-probe") |> render_click()

    assert has_element?(view, "#ice-modal", "CRACKED")
    assert has_element?(view, "#ice-close")

    view |> element("#ice-close") |> render_click()
    refute has_element?(view, "#ice-modal")

    # Node fully cracked -> no longer listed as breakable, reward knowledge granted.
    refute has_element?(view, "#break-gw_test_node")
    assert "gw_node_cracked" in Players.get_player!().knowledge
  end

  test "retreating ends the encounter without cracking the node", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/skills/ghostwork")
    view |> element("#scan-button") |> render_click()
    view |> element("#break-gw_test_node") |> render_click()

    view |> element("#ice-retreat") |> render_click()

    assert has_element?(view, "#ice-close")
    refute "gw_node_cracked" in Players.get_player!().knowledge
  end
end
