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
          trace_multiplier: 1.0,
          reward: [{:knowledge, "gw_node_cracked"}],
          subroutines: [
            %{id: "l1_core", key: nil, threat: :barrier, progress_required: 6}
          ]
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

  test "the deck page renders scan, empty loadout, and the first tier as current", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/skills/ghostwork")

    assert has_element?(view, "#scan-button")
    assert has_element?(view, "#loadout-empty")
    assert has_element?(view, ".ladder-segment--current")
  end

  test "the loadout panel names the active deck and its slot budget", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/skills/ghostwork")

    assert has_element?(view, "#loadout-deck", "Jury-Rigged Terminal")
    assert has_element?(view, "#loadout-deck", "3 slots")
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

  test "scanning an empty lattice does not insert a blank entry into the signal feed",
       %{conn: conn, player_id: pid} do
    :ets.insert(:locations, {"gw_empty_loc", %{id: "gw_empty_loc", name: "Void", lattice: %{}}})
    on_exit(fn -> :ets.delete(:locations, "gw_empty_loc") end)

    Players.dispatch(pid, fn _player ->
      {:ok, [{:set, :location_id, "gw_empty_loc"}], %{}}
    end)

    {:ok, view, _html} = live(conn, ~p"/skills/ghostwork")
    view |> element("#scan-button") |> render_click()
    view |> element("#scan-button") |> render_click()

    assert has_element?(view, "#signal-feed-empty")
  end

  test "a duplicate retreat event does not crash the LiveView", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/skills/ghostwork")
    view |> element("#scan-button") |> render_click()
    view |> element("#break-gw_test_node") |> render_click()

    view |> element("#ice-retreat") |> render_click()
    view |> element("#ice-close") |> render_click()

    assert Process.alive?(view.pid)
    assert has_element?(view, "#scan-button")
  end

  test "a stale act event after close does not crash the LiveView", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/skills/ghostwork")
    view |> element("#scan-button") |> render_click()
    view |> element("#break-gw_test_node") |> render_click()

    view |> element("#ice-retreat") |> render_click()
    view |> element("#ice-close") |> render_click()

    assert Process.alive?(view.pid)
    assert has_element?(view, "#scan-button")
  end

  describe "open-board target selection" do
    setup %{player_id: player_id} do
      node = %IceNode{
        id: "gw_board_node",
        name: "Board Node",
        family: "ice_corp",
        location_id: "gw_test_loc",
        requirements: [{:knows, "gw_node_found"}],
        cool_threshold: 60,
        layers: [
          %{
            id: "only",
            name: "Only Layer",
            trace_multiplier: 1.0,
            reward: [{:knowledge, "gw_board_cracked"}],
            subroutines: [
              %{id: "alpha", key: :spoof, threat: :barrier, progress_required: 10},
              %{id: "beta", key: :decrypt, threat: :barrier, progress_required: 10}
            ]
          }
        ]
      }

      :ets.insert(:ice_nodes, {node.id, node})
      on_exit(fn -> :ets.delete(:ice_nodes, "gw_board_node") end)
      %{player_id: player_id}
    end

    test "probing with no explicit selection hits the first subroutine", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/skills/ghostwork")
      view |> element("#scan-button") |> render_click()
      view |> element("#break-gw_board_node") |> render_click()

      view |> element("#ice-probe") |> render_click()

      assert has_element?(view, "#ice-sub-alpha", "3 / 10")
      assert has_element?(view, "#ice-sub-beta", "0 / 10")
    end

    test "selecting a subroutine targets it for the next action", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/skills/ghostwork")
      view |> element("#scan-button") |> render_click()
      view |> element("#break-gw_board_node") |> render_click()

      view |> element("#ice-sub-beta") |> render_click()
      assert has_element?(view, "#ice-sub-beta.ice-subroutine--selected")

      view |> element("#ice-probe") |> render_click()

      assert has_element?(view, "#ice-sub-beta", "3 / 10")
      assert has_element?(view, "#ice-sub-alpha", "0 / 10")
    end
  end

  describe "breaking the salvage-grid showcase node through its board" do
    setup %{player_id: player_id} do
      Players.dispatch(player_id, fn _player ->
        {:ok,
         [
           {:inventory, "maskchip", 1},
           {:inventory, "shard_reader", 1},
           {:inventory, "ghostkey", 1},
           {:ghostwork_loadout, ["maskchip", "shard_reader", "ghostkey"]},
           {:knowledge, "shunt9_salvage_grid_found"},
           {:set, :location_id, "shunt9_scrap_yard"}
         ], %{}}
      end)

      :ok
    end

    test "selecting subroutines sentry-first cracks the grid and banks its reward",
         %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/skills/ghostwork")

      view |> element("#break-shunt9_salvage_grid") |> render_click()
      assert has_element?(view, "#ice-modal")

      # Layer 1 — intake bolt (spoof): Maskchip matches and clears it, advancing the layer.
      view |> element("#ice-program-maskchip") |> render_click()

      # Layer 2 board — kill the watchdog (sentry) first, then the canary (trap), then the bolt.
      view |> element("#ice-sub-watchdog") |> render_click()
      view |> element("#ice-program-shard_reader") |> render_click()

      view |> element("#ice-sub-canary") |> render_click()
      view |> element("#ice-program-ghostkey") |> render_click()

      view |> element("#ice-sub-load_bolt") |> render_click()
      view |> element("#ice-program-maskchip") |> render_click()

      assert has_element?(view, "#ice-modal", "CRACKED")
      assert "shunt9_salvage_grid_cracked" in Players.get_player!().knowledge
    end
  end

  describe "breaking a node with a vault" do
    setup %{player_id: player_id} do
      node = %IceNode{
        id: "gw_vault_node",
        name: "Vault Relay",
        family: "ice_maintenance",
        location_id: "gw_test_loc",
        requirements: [{:knows, "gw_node_found"}],
        cool_threshold: 60,
        layers: [
          %{
            id: "vl",
            name: "Vaulted",
            trace_multiplier: 1.0,
            reward: [{:knowledge, "gw_vault_safe"}],
            subroutines: [
              %{id: "req", key: nil, threat: :barrier, progress_required: 3},
              %{
                id: "vault",
                key: :decrypt,
                threat: :vault,
                progress_required: 6,
                reward: [{:knowledge, "gw_vault_loot"}]
              }
            ]
          }
        ]
      }

      :ets.insert(:ice_nodes, {node.id, node})
      on_exit(fn -> :ets.delete(:ice_nodes, "gw_vault_node") end)

      # A matching :decrypt program (real content) to drill the vault, plus a mismatched :spoof
      # program (maskchip) that would trip the lockout if it ever hit the vault, plus the reveal.
      Players.dispatch(player_id, fn _player ->
        {:ok,
         [
           {:inventory, "tracebreaker", 1},
           {:inventory, "maskchip", 1},
           {:ghostwork_loadout, ["tracebreaker", "maskchip"]},
           {:knowledge, "gw_node_found"}
         ], %{}}
      end)

      %{player_id: player_id}
    end

    test "the vault subroutine renders sealed with a lockout warning", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/skills/ghostwork")
      view |> element("#break-gw_vault_node") |> render_click()

      assert has_element?(view, "#ice-modal")
      assert has_element?(view, "#ice-sub-vault.ice-subroutine--vault")
      assert has_element?(view, "#ice-sub-vault", "VAULT")
      assert has_element?(view, "#ice-sub-vault", "LOCKOUT")
    end

    test "reading a sealed vault never arms the normal actions against it", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/skills/ghostwork")
      view |> element("#break-gw_vault_node") |> render_click()

      # Highlight the vault to read its stats, then fire a mismatched (:spoof) program: it must
      # hit the required barrier, not the vault. Were it routed at the vault it would lock out, so
      # "still breaking" proves an inspection click can no longer arm a program against the vault.
      view |> element("#ice-sub-vault") |> render_click()
      view |> element("#ice-program-maskchip") |> render_click()

      refute has_element?(view, "#ice-modal", "LOCKED OUT")
      assert has_element?(view, "#ice-modal", "BREAKING")
    end

    test "a cleared-but-open vault layer drops the normal actions and gates the vault behind DRILL",
         %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/skills/ghostwork")
      view |> element("#break-gw_vault_node") |> render_click()

      # Auto-target hits the required barrier; one probe (req = 3) clears the required set.
      view |> element("#ice-probe") |> render_click()

      # Nothing breakable is left, so PROBE and the normal program buttons are gone (not dead) —
      # only DESCEND and RETREAT remain until the vault is deliberately selected.
      refute has_element?(view, "#ice-probe")
      refute has_element?(view, "#ice-program-tracebreaker")
      assert has_element?(view, "#ice-descend")
      assert has_element?(view, "#ice-retreat")

      # Selecting the vault reveals the DRILL affordance — the only path to the vault.
      view |> element("#ice-sub-vault") |> render_click()
      assert has_element?(view, "#ice-drill-tracebreaker")
    end

    test "clearing the required set reveals DESCEND; descending finishes the node", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/skills/ghostwork")
      view |> element("#break-gw_vault_node") |> render_click()

      refute has_element?(view, "#ice-descend")

      # Auto-target skips the vault and hits the required barrier; one probe (3) downs it.
      view |> element("#ice-probe") |> render_click()

      assert has_element?(view, "#ice-descend")

      view |> element("#ice-descend") |> render_click()
      assert has_element?(view, "#ice-modal", "CRACKED")
      refute "gw_vault_loot" in Players.get_player!().knowledge
    end

    test "drilling the vault with its matching key loots it and cracks the node", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/skills/ghostwork")
      view |> element("#break-gw_vault_node") |> render_click()

      view |> element("#ice-probe") |> render_click()

      view |> element("#ice-sub-vault") |> render_click()
      view |> element("#ice-drill-tracebreaker") |> render_click()

      assert has_element?(view, "#ice-modal", "CRACKED")
      assert "gw_vault_loot" in Players.get_player!().knowledge
    end
  end

  describe "the codex read meter" do
    setup %{player_id: player_id} do
      node = %IceNode{
        id: "codex_cov_node",
        name: "Cov",
        family: "ice_testfam",
        location_id: "nowhere",
        requirements: [],
        cool_threshold: 60,
        layers: [
          %{
            id: "l",
            name: "l",
            trace_multiplier: 1.0,
            reward: [],
            subroutines: [%{id: "a", key: :spoof, threat: :barrier, progress_required: 5}]
          }
        ]
      }

      :ets.insert(:ice_nodes, {node.id, node})
      on_exit(fn -> :ets.delete(:ice_nodes, "codex_cov_node") end)

      Players.dispatch(player_id, fn _player ->
        {:ok, [{:inventory, "maskchip", 1}, {:ghostwork_mastery, "ice_testfam", 3}], %{}}
      end)

      %{player_id: player_id}
    end

    test "renders the read meter's KEYS label and actionable coverage", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/skills/ghostwork")

      assert has_element?(view, "#mastery-ice_testfam .ghostwork-read-label", "KEYS")
      assert has_element?(view, "#mastery-ice_testfam .ghostwork-coverage", "spoof")
    end
  end

  describe "encounter key coverage ticks" do
    setup %{player_id: player_id} do
      node = %IceNode{
        id: "gw_cover_node",
        name: "Cover Node",
        family: "ice_corp",
        location_id: "gw_test_loc",
        requirements: [],
        cool_threshold: 60,
        layers: [
          %{
            id: "l",
            name: "l",
            trace_multiplier: 1.0,
            reward: [{:knowledge, "gw_cover_cracked"}],
            subroutines: [
              %{id: "sp", key: :spoof, threat: :barrier, progress_required: 10},
              %{id: "de", key: :decrypt, threat: :barrier, progress_required: 10}
            ]
          }
        ]
      }

      :ets.insert(:ice_nodes, {node.id, node})
      on_exit(fn -> :ets.delete(:ice_nodes, "gw_cover_node") end)

      # Keys read (mastery 3) + a spoof program equipped, so ice wants become legible and one
      # subroutine has a counter in the loadout while the other does not.
      Players.dispatch(player_id, fn _player ->
        {:ok,
         [
           {:inventory, "maskchip", 1},
           {:ghostwork_loadout, ["maskchip"]},
           {:ghostwork_mastery, "ice_corp", 3}
         ], %{}}
      end)

      %{player_id: player_id}
    end

    test "a subroutine the loadout counters shows a tick; an uncountered one does not", %{
      conn: conn
    } do
      {:ok, view, _html} = live(conn, ~p"/skills/ghostwork")
      view |> element("#break-gw_cover_node") |> render_click()

      assert has_element?(view, "#ice-sub-sp .ice-subroutine-counter")
      refute has_element?(view, "#ice-sub-de .ice-subroutine-counter")
    end
  end

  describe "loadout management on the rail" do
    setup %{player_id: player_id} do
      Players.dispatch(player_id, fn _player ->
        {:ok,
         [
           {:inventory, "maskchip", 1},
           {:inventory, "shard_reader", 1},
           {:inventory, "ghostkey", 1},
           {:inventory, "signal_knife", 1}
         ], %{}}
      end)

      :ok
    end

    test "equipping a program marks it equipped and counts it", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/skills/ghostwork")

      view |> element("#equip-maskchip") |> render_click()

      assert has_element?(view, "#unequip-maskchip")
      assert has_element?(view, "#loadout-count", "1/3")
    end

    test "equipping past three slots disables further equips", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/skills/ghostwork")

      view |> element("#equip-maskchip") |> render_click()
      view |> element("#equip-shard_reader") |> render_click()
      view |> element("#equip-ghostkey") |> render_click()

      assert has_element?(view, "#loadout-count", "3/3")
      assert has_element?(view, "#equip-signal_knife[disabled]")
    end

    test "unequipping returns a program to the available state", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/skills/ghostwork")

      view |> element("#equip-maskchip") |> render_click()
      view |> element("#unequip-maskchip") |> render_click()

      assert has_element?(view, "#equip-maskchip")
      assert has_element?(view, "#loadout-count", "0/3")
    end

    test "the encounter action bar lists only equipped programs", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/skills/ghostwork")

      view |> element("#equip-maskchip") |> render_click()

      view |> element("#scan-button") |> render_click()
      view |> element("#break-gw_test_node") |> render_click()

      assert has_element?(view, "#ice-program-maskchip")
      refute has_element?(view, "#ice-program-ghostkey")
    end
  end
end
