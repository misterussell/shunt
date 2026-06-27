defmodule ShuntWeb.WebLiveTest do
  use ShuntWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Shunt.Events.Event
  alias Shunt.Web.Rumor
  alias Shunt.Web.RumorConnection

  # Connection: a, b, c — partial_threshold: 2
  # d, e are unrelated (no overlap with any connection — used for no-match test)
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

    partial_event = %Event{
      id: "test_web_partial",
      title: "A Lead",
      steps: [
        %{id: "hint", text: "You're close.", choices: [%{label: "Understood", complete: true}]}
      ],
      on_complete: [{:rumor, "test_rumor_c"}]
    }

    :ets.insert(:rumors, Enum.map(rumors, &{&1.id, &1}))
    :ets.insert(:rumor_connections, {conn.id, conn})
    :ets.insert(:events, [{success_event.id, success_event}, {partial_event.id, partial_event}])

    on_exit(fn ->
      Enum.each(rumors, &:ets.delete(:rumors, &1.id))
      :ets.delete(:rumor_connections, conn.id)
      :ets.delete(:events, success_event.id)
      :ets.delete(:events, partial_event.id)
    end)

    %{player: player}
  end

  describe "board — empty state" do
    test "shows the empty state panel when the player has no rumors", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/skills/the-web")

      assert has_element?(view, "#board-empty")
      refute has_element?(view, "#rumor-collection")
    end
  end

  describe "board — rumor collection" do
    test "renders a card for each collected rumor", %{conn: conn, player: player} do
      give_player_rumors(player, ["test_rumor_a", "test_rumor_b"])

      {:ok, view, _html} = live(conn, ~p"/skills/the-web")

      assert has_element?(view, "#rumor-collection")
      assert has_element?(view, "#rumor-test_rumor_a", "Intel A")
      assert has_element?(view, "#rumor-test_rumor_b", "Intel B")
      refute has_element?(view, "#board-empty")
    end

    test "does not render a card for rumors the player has not collected", %{
      conn: conn,
      player: player
    } do
      give_player_rumors(player, ["test_rumor_a"])

      {:ok, view, _html} = live(conn, ~p"/skills/the-web")

      assert has_element?(view, "#rumor-test_rumor_a")
      refute has_element?(view, "#rumor-test_rumor_b")
    end
  end

  describe "toggle_rumor" do
    test "clicking a rumor card selects it", %{conn: conn, player: player} do
      give_player_rumors(player, ["test_rumor_a"])

      {:ok, view, _html} = live(conn, ~p"/skills/the-web")

      view |> element("#rumor-test_rumor_a") |> render_click()

      assert has_element?(view, "#rumor-test_rumor_a.selected")
    end

    test "clicking a selected rumor card deselects it", %{conn: conn, player: player} do
      give_player_rumors(player, ["test_rumor_a"])

      {:ok, view, _html} = live(conn, ~p"/skills/the-web")

      view |> element("#rumor-test_rumor_a") |> render_click()
      view |> element("#rumor-test_rumor_a") |> render_click()

      refute has_element?(view, "#rumor-test_rumor_a.selected")
    end
  end

  describe "investigate button" do
    test "is disabled when fewer than 2 rumors are selected", %{conn: conn, player: player} do
      give_player_rumors(player, ["test_rumor_a"])

      {:ok, view, _html} = live(conn, ~p"/skills/the-web")

      view |> element("#rumor-test_rumor_a") |> render_click()

      assert has_element?(view, "#investigate-button[disabled]")
    end

    test "is enabled once 2 or more rumors are selected", %{conn: conn, player: player} do
      give_player_rumors(player, ["test_rumor_a", "test_rumor_b"])

      {:ok, view, _html} = live(conn, ~p"/skills/the-web")

      view |> element("#rumor-test_rumor_a") |> render_click()
      view |> element("#rumor-test_rumor_b") |> render_click()

      refute has_element?(view, "#investigate-button[disabled]")
    end
  end

  describe "investigate — success" do
    test "an exact-match theory opens the success event panel", %{conn: conn, player: player} do
      give_player_rumors(player, ["test_rumor_a", "test_rumor_b", "test_rumor_c"])

      {:ok, view, _html} = live(conn, ~p"/skills/the-web")

      view |> element("#rumor-test_rumor_a") |> render_click()
      view |> element("#rumor-test_rumor_b") |> render_click()
      view |> element("#rumor-test_rumor_c") |> render_click()
      view |> element("#investigate-button") |> render_click()

      assert has_element?(view, "#active-event", "The pieces fit.")
    end

    test "completing the success event applies rewards and closes the event panel", %{
      conn: conn,
      player: player
    } do
      give_player_rumors(player, ["test_rumor_a", "test_rumor_b", "test_rumor_c"])

      {:ok, view, _html} = live(conn, ~p"/skills/the-web")

      view |> element("#rumor-test_rumor_a") |> render_click()
      view |> element("#rumor-test_rumor_b") |> render_click()
      view |> element("#rumor-test_rumor_c") |> render_click()
      view |> element("#investigate-button") |> render_click()

      view
      |> element("#active-event [phx-click='event_choice']", "Continue")
      |> render_click()

      refute has_element?(view, "#active-event")
      assert Shunt.Players.get_player!().scrip == 100
    end
  end

  describe "investigate — partial" do
    test "a partial-match theory opens the partial event panel", %{conn: conn, player: player} do
      # Submitting a and b (2 of 3) meets partial_threshold: 2 but is not exact
      give_player_rumors(player, ["test_rumor_a", "test_rumor_b"])

      {:ok, view, _html} = live(conn, ~p"/skills/the-web")

      view |> element("#rumor-test_rumor_a") |> render_click()
      view |> element("#rumor-test_rumor_b") |> render_click()
      view |> element("#investigate-button") |> render_click()

      assert has_element?(view, "#active-event", "You're close.")
    end
  end

  describe "investigate — no match" do
    test "a theory with no connection overlap shows the no-match status message", %{
      conn: conn,
      player: player
    } do
      # d and e have zero overlap with the connection [a, b, c]
      give_player_rumors(player, ["test_rumor_d", "test_rumor_e"])

      {:ok, view, _html} = live(conn, ~p"/skills/the-web")

      view |> element("#rumor-test_rumor_d") |> render_click()
      view |> element("#rumor-test_rumor_e") |> render_click()
      view |> element("#investigate-button") |> render_click()

      assert has_element?(view, "#status-bar", "NO MATCHING INVESTIGATION")
    end
  end

  describe "clear" do
    test "clicking clear deselects all selected rumors", %{conn: conn, player: player} do
      give_player_rumors(player, ["test_rumor_a", "test_rumor_b"])

      {:ok, view, _html} = live(conn, ~p"/skills/the-web")

      view |> element("#rumor-test_rumor_a") |> render_click()
      view |> element("#rumor-test_rumor_b") |> render_click()
      view |> element("#clear-button") |> render_click()

      refute has_element?(view, "#rumor-test_rumor_a.selected")
      refute has_element?(view, "#rumor-test_rumor_b.selected")
    end
  end

  describe "dev — seed rumors" do
    test "renders the dev seed control", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/skills/the-web")

      assert has_element?(view, "#seed-rumors-button")
    end

    test "clicking seed rumors populates the board with rumor cards", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/skills/the-web")

      assert has_element?(view, "#board-empty")

      view |> element("#seed-rumors-button") |> render_click()

      assert has_element?(view, "#rumor-collection")
      refute has_element?(view, "#board-empty")
    end
  end

  defp give_player_rumors(player, rumor_ids) do
    Shunt.Players.dispatch(player.id, fn _p ->
      {:ok, Enum.map(rumor_ids, &{:rumor, &1}), %{}}
    end)
  end
end
