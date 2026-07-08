defmodule ShuntWeb.WebLiveTest do
  use ShuntWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Shunt.Events.Event
  alias Shunt.Web.Rumor
  alias Shunt.Web.RumorConnection

  # Connection test_conn = a, b, c (partial_threshold 2). d is unrelated to any case.
  setup do
    player = Shunt.Players.create_player!()

    rumors = [
      %Rumor{
        id: "test_rumor_a",
        title: "Intel A",
        description: "First.",
        source: "npc",
        origin: "Overheard in the back-rows",
        tags: ["juno"]
      },
      %Rumor{
        id: "test_rumor_b",
        title: "Intel B",
        description: "Second.",
        source: "npc",
        tags: []
      },
      %Rumor{
        id: "test_rumor_c",
        title: "Intel C",
        description: "Third.",
        source: "npc",
        origin: "Whispered in the stacks",
        tags: []
      },
      %Rumor{
        id: "test_rumor_d",
        title: "Intel D",
        description: "Unrelated.",
        source: "npc",
        tags: []
      }
    ]

    conn_data = %RumorConnection{
      id: "test_conn",
      rumors: ["test_rumor_a", "test_rumor_b", "test_rumor_c"],
      partial_threshold: 2,
      success_event_id: "test_web_success",
      partial_event_id: "test_web_partial",
      failure_event_id: "test_web_failure",
      lead_heat: 2,
      crack_heat: 5
    }

    success_event = %Event{
      id: "test_web_success",
      title: "Breakthrough",
      steps: [
        %{id: "reveal", text: "The pieces fit.", choices: [%{label: "Continue", complete: true}]}
      ],
      on_complete: [{:scrip, 100}]
    }

    partial_event = %Event{
      id: "test_web_partial",
      title: "Partial Read",
      repeatable: false,
      steps: [
        %{
          id: "partial",
          text: "A thread, not the whole cloth.",
          choices: [%{label: "Keep digging", complete: true}]
        }
      ],
      on_complete: []
    }

    :ets.insert(:rumors, Enum.map(rumors, &{&1.id, &1}))
    :ets.insert(:rumor_connections, {conn_data.id, conn_data})
    :ets.insert(:events, [{success_event.id, success_event}, {partial_event.id, partial_event}])

    on_exit(fn ->
      Enum.each(rumors, &:ets.delete(:rumors, &1.id))
      :ets.delete(:rumor_connections, conn_data.id)
      :ets.delete(:events, success_event.id)
      :ets.delete(:events, partial_event.id)
    end)

    %{player: player}
  end

  describe "empty state" do
    test "shows the empty state when the player holds no rumors", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/skills/the-web")

      assert has_element?(view, "#web-empty")
      refute has_element?(view, "#signal-network")
    end

    test "shows the empty state when held rumors touch no case", %{conn: conn, player: player} do
      give_player_rumors(player, ["test_rumor_d"])

      {:ok, view, _html} = live(conn, ~p"/skills/the-web")

      assert has_element?(view, "#web-empty")
    end
  end

  describe "cases — status" do
    test "a below-threshold holding renders a forming case with no action button", %{
      conn: conn,
      player: player
    } do
      give_player_rumors(player, ["test_rumor_a"])

      {:ok, view, _html} = live(conn, ~p"/skills/the-web")

      assert has_element?(view, "#signal-network")
      assert has_element?(view, "#case-test_conn[data-status='forming']")
      assert has_element?(view, "#case-test_conn", "1/3")
      refute has_element?(view, "#lead-test_conn")
      refute has_element?(view, "#crack-test_conn")
    end

    test "a threshold holding renders a lead case with a heat-priced FOLLOW LEAD", %{
      conn: conn,
      player: player
    } do
      give_player_rumors(player, ["test_rumor_a", "test_rumor_b"])

      {:ok, view, _html} = live(conn, ~p"/skills/the-web")

      assert has_element?(view, "#case-test_conn[data-status='lead']")
      assert has_element?(view, "#lead-test_conn", "FOLLOW LEAD")
      assert has_element?(view, "#lead-test_conn", "2")
      refute has_element?(view, "#crack-test_conn")
    end

    test "a full holding renders a crackable case with a heat-priced CRACK", %{
      conn: conn,
      player: player
    } do
      give_player_rumors(player, ["test_rumor_a", "test_rumor_b", "test_rumor_c"])

      {:ok, view, _html} = live(conn, ~p"/skills/the-web")

      assert has_element?(view, "#case-test_conn[data-status='crackable']")
      assert has_element?(view, "#crack-test_conn", "CRACK")
      assert has_element?(view, "#crack-test_conn", "5")
    end
  end

  describe "cases — recall and redaction" do
    test "held rumors are listed by title", %{conn: conn, player: player} do
      give_player_rumors(player, ["test_rumor_a"])

      {:ok, view, _html} = live(conn, ~p"/skills/the-web")

      assert has_element?(view, "#case-test_conn", "Intel A")
    end

    test "a missing rumor shows a redacted slot with its origin hint, not its content", %{
      conn: conn,
      player: player
    } do
      # Hold a and b; c (origin: "Whispered in the stacks") is missing.
      give_player_rumors(player, ["test_rumor_a", "test_rumor_b"])

      {:ok, view, _html} = live(conn, ~p"/skills/the-web")

      assert has_element?(view, "#case-test_conn", "Whispered in the stacks")
      refute has_element?(view, "#case-test_conn", "Intel C")
    end
  end

  describe "pursue" do
    test "CRACK opens the success event and charges crack_heat", %{conn: conn, player: player} do
      give_player_rumors(player, ["test_rumor_a", "test_rumor_b", "test_rumor_c"])

      {:ok, view, _html} = live(conn, ~p"/skills/the-web")

      view |> element("#crack-test_conn") |> render_click()

      assert has_element?(view, "#active-event", "The pieces fit.")
      assert Shunt.Players.get_player!().heat == 5
    end

    test "FOLLOW LEAD opens the partial event and charges lead_heat", %{
      conn: conn,
      player: player
    } do
      give_player_rumors(player, ["test_rumor_a", "test_rumor_b"])

      {:ok, view, _html} = live(conn, ~p"/skills/the-web")

      view |> element("#lead-test_conn") |> render_click()

      assert has_element?(view, "#active-event", "A thread")
      assert Shunt.Players.get_player!().heat == 2
    end

    test "action buttons are hidden while an event is open", %{conn: conn, player: player} do
      give_player_rumors(player, ["test_rumor_a", "test_rumor_b", "test_rumor_c"])

      {:ok, view, _html} = live(conn, ~p"/skills/the-web")

      view |> element("#crack-test_conn") |> render_click()

      assert has_element?(view, "#active-event")
      refute has_element?(view, "#crack-test_conn")
    end

    test "completing the crack event applies rewards and marks the case solved", %{
      conn: conn,
      player: player
    } do
      give_player_rumors(player, ["test_rumor_a", "test_rumor_b", "test_rumor_c"])

      {:ok, view, _html} = live(conn, ~p"/skills/the-web")

      view |> element("#crack-test_conn") |> render_click()

      view
      |> element("#active-event [phx-click='event_choice']", "Continue")
      |> render_click()

      refute has_element?(view, "#active-event")
      assert Shunt.Players.get_player!().scrip == 100
      assert has_element?(view, "#case-test_conn[data-status='solved']")
      refute has_element?(view, "#crack-test_conn")
    end

    test "a stale/unknown connection_id is a no-op, not a crash", %{conn: conn, player: player} do
      give_player_rumors(player, ["test_rumor_a", "test_rumor_b", "test_rumor_c"])

      {:ok, view, _html} = live(conn, ~p"/skills/the-web")

      render_hook(view, "pursue", %{"connection_id" => "no_such_connection", "mode" => "crack"})

      refute has_element?(view, "#active-event")
      assert has_element?(view, "#crack-test_conn")
    end
  end

  describe "dev — seed rumors" do
    test "renders the dev seed control and populates the network", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/skills/the-web")

      assert has_element?(view, "#seed-rumors-button")
      assert has_element?(view, "#web-empty")

      view |> element("#seed-rumors-button") |> render_click()

      assert has_element?(view, "#signal-network")
      refute has_element?(view, "#web-empty")
    end

    test "the wipe-board dev control is gone", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/skills/the-web")

      refute has_element?(view, "#wipe-board-button")
    end
  end

  describe "cases / entities toggle" do
    test "defaults to the cases view with both toggle controls present", %{
      conn: conn,
      player: player
    } do
      give_player_rumors(player, ["test_rumor_a"])

      {:ok, view, _html} = live(conn, ~p"/skills/the-web")

      assert has_element?(view, "#view-cases")
      assert has_element?(view, "#view-entities")
      assert has_element?(view, "#signal-network")
      refute has_element?(view, "#entities-view")
    end

    test "switching to entities shows the facet rail and hides the cases list", %{
      conn: conn,
      player: player
    } do
      give_player_rumors(player, ["test_rumor_a"])

      {:ok, view, _html} = live(conn, ~p"/skills/the-web")

      view |> element("#view-entities") |> render_click()

      assert has_element?(view, "#entities-view")
      assert has_element?(view, "#entity-juno")
      refute has_element?(view, "#signal-network")
    end
  end

  describe "entities view" do
    test "selecting an entity shows its held rumors and the cases it touches", %{
      conn: conn,
      player: player
    } do
      give_player_rumors(player, ["test_rumor_a"])

      {:ok, view, _html} = live(conn, ~p"/skills/the-web")

      view |> element("#view-entities") |> render_click()
      view |> element("#entity-juno") |> render_click()

      assert has_element?(view, "#entity-detail", "Intel A")
      assert has_element?(view, "#entity-detail #case-test_conn")
    end

    test "the entity detail defaults to the top-signal entity before any click", %{
      conn: conn,
      player: player
    } do
      give_player_rumors(player, ["test_rumor_a"])

      {:ok, view, _html} = live(conn, ~p"/skills/the-web")

      view |> element("#view-entities") |> render_click()

      # juno is the only entity, so the web auto-focuses it and the detail shows its intel.
      assert has_element?(view, "#entity-detail", "Intel A")
      assert has_element?(view, "#entity-detail #case-test_conn")
    end
  end

  describe "signal web (entities view)" do
    setup do
      # A two-hop chain: alpha–beta (web_ab) and beta–gamma (web_bc). alpha and gamma share no
      # rumor, so the focal neighborhood is provably local — the web never draws the whole graph.
      rumors = [
        %Rumor{
          id: "web_ab",
          title: "AB",
          description: "…",
          source: "npc",
          tags: ["alpha", "beta"]
        },
        %Rumor{
          id: "web_bc",
          title: "BC",
          description: "…",
          source: "npc",
          tags: ["beta", "gamma"]
        }
      ]

      :ets.insert(:rumors, Enum.map(rumors, &{&1.id, &1}))
      on_exit(fn -> Enum.each(rumors, &:ets.delete(:rumors, &1.id)) end)
      :ok
    end

    test "centers on the top-signal entity and shows its neighbors, with the chip-rail fallback",
         %{conn: conn, player: player} do
      give_player_rumors(player, ["web_ab", "web_bc"])

      {:ok, view, _html} = live(conn, ~p"/skills/the-web")
      view |> element("#view-entities") |> render_click()

      # beta is the hub (weight 2) -> default focus; alpha and gamma are its neighbors.
      assert has_element?(view, "#entity-web")
      assert has_element?(view, "#web-node-beta")
      assert has_element?(view, "#web-node-alpha")
      assert has_element?(view, "#web-node-gamma")
      assert has_element?(view, "#entity-rail #entity-beta")
    end

    test "draws only the focal entity's neighborhood", %{conn: conn, player: player} do
      give_player_rumors(player, ["web_ab", "web_bc"])

      {:ok, view, _html} = live(conn, ~p"/skills/the-web")
      view |> element("#view-entities") |> render_click()
      view |> element("#web-node-alpha") |> render_click()

      # Focused on alpha: beta is a neighbor; gamma (two hops away) is not drawn.
      assert has_element?(view, "#web-node-beta")
      refute has_element?(view, "#web-node-gamma")
    end

    test "clicking a node re-centers the web on it", %{conn: conn, player: player} do
      give_player_rumors(player, ["web_ab", "web_bc"])

      {:ok, view, _html} = live(conn, ~p"/skills/the-web")
      view |> element("#view-entities") |> render_click()
      view |> element("#web-node-alpha") |> render_click()
      refute has_element?(view, "#web-node-gamma")

      view |> element("#web-node-beta") |> render_click()
      assert has_element?(view, "#web-node-gamma")
    end

    test "threads carry a data-status attribute", %{conn: conn, player: player} do
      give_player_rumors(player, ["web_ab"])

      {:ok, view, _html} = live(conn, ~p"/skills/the-web")
      view |> element("#view-entities") |> render_click()

      assert has_element?(view, "#entity-web [data-status]")
    end
  end

  defp give_player_rumors(player, rumor_ids) do
    Shunt.Players.dispatch(player.id, fn _p ->
      {:ok, Enum.map(rumor_ids, &{:rumor, &1}), %{}}
    end)
  end
end
