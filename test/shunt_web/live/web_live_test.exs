defmodule ShuntWeb.WebLiveTest do
  use ShuntWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Shunt.Events.Event
  alias Shunt.Web.Rumor
  alias Shunt.Web.RumorConnection

  # Connection: a, b, c — partial_threshold: 2
  # d, e are unrelated (no overlap with any connection)
  setup do
    player = Shunt.Players.create_player!()

    rumors = [
      %Rumor{
        id: "test_rumor_a",
        title: "Intel A",
        description: "First.",
        source: "npc",
        tags: []
      },
      %Rumor{
        id: "test_rumor_b",
        title: "Intel B",
        description: "Second.",
        source: "latticework",
        tags: []
      },
      %Rumor{
        id: "test_rumor_c",
        title: "Intel C",
        description: "Third.",
        source: "npc",
        tags: []
      },
      %Rumor{
        id: "test_rumor_d",
        title: "Intel D",
        description: "Unrelated.",
        source: "npc",
        tags: []
      },
      %Rumor{
        id: "test_rumor_e",
        title: "Intel E",
        description: "Unrelated.",
        source: "npc",
        tags: []
      }
    ]

    conn = %RumorConnection{
      id: "test_conn",
      rumors: ["test_rumor_a", "test_rumor_b", "test_rumor_c"],
      partial_threshold: 2,
      success_event_id: "test_web_success",
      partial_event_id: "test_web_partial",
      failure_event_id: "test_web_failure"
    }

    success_event = %Event{
      id: "test_web_success",
      title: "Breakthrough",
      steps: [
        %{id: "reveal", text: "The pieces fit.", choices: [%{label: "Continue", complete: true}]}
      ],
      on_complete: [{:scrip, 100}]
    }

    :ets.insert(:rumors, Enum.map(rumors, &{&1.id, &1}))
    :ets.insert(:rumor_connections, {conn.id, conn})
    :ets.insert(:events, [{success_event.id, success_event}])

    on_exit(fn ->
      Enum.each(rumors, &:ets.delete(:rumors, &1.id))
      :ets.delete(:rumor_connections, conn.id)
      :ets.delete(:events, success_event.id)
    end)

    %{player: player}
  end

  describe "board — empty state" do
    test "shows the empty state panel when the player has no rumors", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/skills/the-web")

      assert has_element?(view, "#board-empty")
      refute has_element?(view, "#web-board")
    end
  end

  describe "intake rail" do
    test "collected but unplaced rumors appear in the intake rail", %{conn: conn, player: player} do
      give_player_rumors(player, ["test_rumor_a", "test_rumor_b"])

      {:ok, view, _html} = live(conn, ~p"/skills/the-web")

      assert has_element?(view, "#web-board")
      assert has_element?(view, "#intake-test_rumor_a", "Intel A")
      assert has_element?(view, "#intake-test_rumor_b", "Intel B")
      refute has_element?(view, "#board-empty")
    end
  end

  describe "desktop layout" do
    test "the board page renders in the wide shell", %{conn: conn, player: player} do
      give_player_rumors(player, ["test_rumor_a"])

      {:ok, view, _html} = live(conn, ~p"/skills/the-web")

      assert has_element?(view, "main.main-content--wide")
    end

    test "the rumors view is laid out as a three-pane grid", %{conn: conn, player: player} do
      give_player_rumors(player, ["test_rumor_a"])

      {:ok, view, _html} = live(conn, ~p"/skills/the-web")

      assert has_element?(view, "#web-grid")
      assert has_element?(view, "#web-grid #intake-rail")
      assert has_element?(view, "#web-grid #web-board")
      assert has_element?(view, "#web-grid #board-rail #board-signals")
      assert has_element?(view, "#web-grid #board-rail #board-dossier")
    end
  end

  describe "place_rumor" do
    test "moves a rumor from the intake rail onto the board", %{conn: conn, player: player} do
      give_player_rumors(player, ["test_rumor_a"])

      {:ok, view, _html} = live(conn, ~p"/skills/the-web")

      render_hook(view, "place_rumor", %{"id" => "test_rumor_a", "x" => "0.5", "y" => "0.5"})

      assert has_element?(view, "#rumor-test_rumor_a[data-x='0.5'][data-y='0.5']")
      refute has_element?(view, "#intake-test_rumor_a")
    end

    test "clamps out-of-range coordinates into 0.0..1.0", %{conn: conn, player: player} do
      give_player_rumors(player, ["test_rumor_a"])

      {:ok, view, _html} = live(conn, ~p"/skills/the-web")

      render_hook(view, "place_rumor", %{"id" => "test_rumor_a", "x" => "2.5", "y" => "-1.0"})

      assert has_element?(view, "#rumor-test_rumor_a[data-x='1.0'][data-y='0.0']")
    end
  end

  describe "move_rumor" do
    test "repositions an already-placed rumor", %{conn: conn, player: player} do
      give_player_rumors(player, ["test_rumor_a"])

      {:ok, view, _html} = live(conn, ~p"/skills/the-web")

      render_hook(view, "place_rumor", %{"id" => "test_rumor_a", "x" => "0.1", "y" => "0.1"})
      render_hook(view, "move_rumor", %{"id" => "test_rumor_a", "x" => "0.8", "y" => "0.9"})

      assert has_element?(view, "#rumor-test_rumor_a[data-x='0.8'][data-y='0.9']")
    end
  end

  describe "connect / disconnect" do
    test "connect wires two placed rumors together", %{conn: conn, player: player} do
      give_player_rumors(player, ["test_rumor_a", "test_rumor_b"])

      {:ok, view, _html} = live(conn, ~p"/skills/the-web")

      render_hook(view, "place_rumor", %{"id" => "test_rumor_a", "x" => "0.1", "y" => "0.1"})
      render_hook(view, "place_rumor", %{"id" => "test_rumor_b", "x" => "0.2", "y" => "0.2"})
      render_hook(view, "connect", %{"a" => "test_rumor_a", "b" => "test_rumor_b"})

      assert Shunt.Players.get_player!().web_board["wires"] == [["test_rumor_a", "test_rumor_b"]]
    end

    test "disconnect removes the wire", %{conn: conn, player: player} do
      give_player_rumors(player, ["test_rumor_a", "test_rumor_b"])

      {:ok, view, _html} = live(conn, ~p"/skills/the-web")

      render_hook(view, "connect", %{"a" => "test_rumor_a", "b" => "test_rumor_b"})
      render_hook(view, "disconnect", %{"a" => "test_rumor_a", "b" => "test_rumor_b"})

      assert Shunt.Players.get_player!().web_board["wires"] == []
    end
  end

  describe "return_to_intake" do
    test "pulls a placed rumor back to the intake rail", %{conn: conn, player: player} do
      give_player_rumors(player, ["test_rumor_a"])

      {:ok, view, _html} = live(conn, ~p"/skills/the-web")

      render_hook(view, "place_rumor", %{"id" => "test_rumor_a", "x" => "0.5", "y" => "0.5"})
      render_hook(view, "return_to_intake", %{"id" => "test_rumor_a"})

      assert has_element?(view, "#intake-test_rumor_a")
      refute has_element?(view, "#rumor-test_rumor_a")
    end
  end

  describe "resonance" do
    test "an exact wired cluster surfaces the inline CONNECT control", %{
      conn: conn,
      player: player
    } do
      give_player_rumors(player, ["test_rumor_a", "test_rumor_b", "test_rumor_c"])

      {:ok, view, _html} = live(conn, ~p"/skills/the-web")

      build_cluster(view, ["test_rumor_a", "test_rumor_b", "test_rumor_c"])

      assert has_element?(view, "#connect-test_conn")
      assert has_element?(view, "#rumor-test_rumor_a[data-resonant='true']")
    end

    test "a partial cluster stays silent (no CONNECT)", %{conn: conn, player: player} do
      give_player_rumors(player, ["test_rumor_a", "test_rumor_b"])

      {:ok, view, _html} = live(conn, ~p"/skills/the-web")

      build_cluster(view, ["test_rumor_a", "test_rumor_b"])

      refute has_element?(view, "#connect-test_conn")
      assert has_element?(view, "#rumor-test_rumor_a[data-resonant='false']")
    end
  end

  describe "connect_theory" do
    test "clicking CONNECT on a resonant cluster opens the success event", %{
      conn: conn,
      player: player
    } do
      give_player_rumors(player, ["test_rumor_a", "test_rumor_b", "test_rumor_c"])

      {:ok, view, _html} = live(conn, ~p"/skills/the-web")

      build_cluster(view, ["test_rumor_a", "test_rumor_b", "test_rumor_c"])
      view |> element("#connect-test_conn") |> render_click()

      assert has_element?(view, "#active-event", "The pieces fit.")
    end

    test "completing the event applies rewards and locks the solved cluster", %{
      conn: conn,
      player: player
    } do
      give_player_rumors(player, ["test_rumor_a", "test_rumor_b", "test_rumor_c"])

      {:ok, view, _html} = live(conn, ~p"/skills/the-web")

      build_cluster(view, ["test_rumor_a", "test_rumor_b", "test_rumor_c"])
      view |> element("#connect-test_conn") |> render_click()

      view
      |> element("#active-event [phx-click='event_choice']", "Continue")
      |> render_click()

      refute has_element?(view, "#active-event")
      assert Shunt.Players.get_player!().scrip == 100
      assert has_element?(view, "#rumor-test_rumor_a[data-solved='true']")
    end
  end

  describe "connect_theory — guards" do
    test "an unknown/stale connection_id is a no-op (no MatchError crash)", %{
      conn: conn,
      player: player
    } do
      give_player_rumors(player, ["test_rumor_a", "test_rumor_b", "test_rumor_c"])

      {:ok, view, _html} = live(conn, ~p"/skills/the-web")

      build_cluster(view, ["test_rumor_a", "test_rumor_b", "test_rumor_c"])
      render_hook(view, "connect_theory", %{"connection_id" => "no_such_connection"})

      refute has_element?(view, "#active-event")
      assert has_element?(view, "#connect-test_conn")
    end

    test "the CONNECT control is hidden while an event is already open", %{
      conn: conn,
      player: player
    } do
      give_player_rumors(player, ["test_rumor_a", "test_rumor_b", "test_rumor_c"])

      {:ok, view, _html} = live(conn, ~p"/skills/the-web")

      build_cluster(view, ["test_rumor_a", "test_rumor_b", "test_rumor_c"])
      view |> element("#connect-test_conn") |> render_click()

      assert has_element?(view, "#active-event")
      refute has_element?(view, "#connect-test_conn")
    end

    test "a re-pushed connect_theory while an event is open does not restart it", %{
      conn: conn,
      player: player
    } do
      give_player_rumors(player, ["test_rumor_a", "test_rumor_b", "test_rumor_c"])

      {:ok, view, _html} = live(conn, ~p"/skills/the-web")

      build_cluster(view, ["test_rumor_a", "test_rumor_b", "test_rumor_c"])
      view |> element("#connect-test_conn") |> render_click()
      render_hook(view, "connect_theory", %{"connection_id" => "test_conn"})

      assert has_element?(view, "#active-event", "The pieces fit.")
    end
  end

  describe "board — missing content is tolerated" do
    test "a placed rumor whose content was removed is skipped, not crashed", %{
      conn: conn,
      player: player
    } do
      give_player_rumors(player, ["test_rumor_a"])

      {:ok, _p, _m} =
        Shunt.Players.dispatch(player.id, &Shunt.Web.place_rumor(&1, "test_rumor_a", 0.5, 0.5))

      :ets.delete(:rumors, "test_rumor_a")

      {:ok, view, _html} = live(conn, ~p"/skills/the-web")

      assert has_element?(view, "#web-board")
      refute has_element?(view, "#rumor-test_rumor_a")
    end
  end

  describe "dev — seed rumors" do
    test "renders the dev seed control", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/skills/the-web")

      assert has_element?(view, "#seed-rumors-button")
    end

    test "clicking seed rumors populates the intake rail", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/skills/the-web")

      assert has_element?(view, "#board-empty")

      view |> element("#seed-rumors-button") |> render_click()

      assert has_element?(view, "#web-board")
      refute has_element?(view, "#board-empty")
    end
  end

  describe "dev — wipe board" do
    test "renders the dev wipe control", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/skills/the-web")

      assert has_element?(view, "#wipe-board-button")
    end

    test "clicking wipe board clears positions and wires", %{conn: conn, player: player} do
      {:ok, _player, _meta} = Shunt.Players.dispatch(player.id, &Shunt.Web.connect(&1, "x", "y"))

      {:ok, view, _html} = live(conn, ~p"/skills/the-web")

      view |> element("#wipe-board-button") |> render_click()

      assert Shunt.Players.get_player!().web_board == %{"positions" => %{}, "wires" => []}
    end
  end

  # Places every rumor and wires them into one connected cluster (chain), as the JS hook would.
  defp build_cluster(view, rumor_ids) do
    Enum.each(rumor_ids, fn id ->
      render_hook(view, "place_rumor", %{"id" => id, "x" => "0.3", "y" => "0.3"})
    end)

    rumor_ids
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.each(fn [a, b] -> render_hook(view, "connect", %{"a" => a, "b" => b}) end)
  end

  defp give_player_rumors(player, rumor_ids) do
    Shunt.Players.dispatch(player.id, fn _p ->
      {:ok, Enum.map(rumor_ids, &{:rumor, &1}), %{}}
    end)
  end
end
