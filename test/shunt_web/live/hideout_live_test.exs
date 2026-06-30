defmodule ShuntWeb.HideoutLiveTest do
  use ShuntWeb.ConnCase

  import ExUnit.CaptureLog, only: [with_log: 1]
  import Phoenix.LiveViewTest

  alias Shunt.Players

  setup do
    Players.create_player!()
    :ok
  end

  # Apply setup effects through the real dispatch path so the running player server (which the
  # LiveView reads via Players.current/1) reflects them.
  defp setup_state(effects) do
    Players.dispatch(Players.get_player!().id, fn _player -> {:ok, effects} end)
  end

  describe "access gate" do
    test "redirects to /map when the player is not at their premises", %{conn: conn} do
      setup_state([{:set, :location_id, "shunt9_maintenance_tunnel"}])

      assert {:error, {:redirect, %{to: "/map"}}} = live(conn, ~p"/hideout")
    end

    test "renders the hideout when the player is home (location_id == premises_id)", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/hideout")

      assert has_element?(view, "#hideout")
      # default player owns no modules -> Squatter
      assert has_element?(view, "#hideout-tier", "Squatter")
    end
  end

  describe "the bleed (income)" do
    test "collecting a non-empty reservoir banks scrip and clears the reservoir", %{conn: conn} do
      three_hours_ago =
        DateTime.utc_now() |> DateTime.add(-3 * 3600, :second) |> DateTime.truncate(:second)

      setup_state([
        {:install_module, "latticework_bleed"},
        {:set, :last_collected, three_hours_ago}
      ])

      {:ok, view, _html} = live(conn, ~p"/hideout")

      assert has_element?(view, "#bleed-collect")
      view |> element("#bleed-collect") |> render_click()

      # ~3h * 5 scrip/hr = 15 banked; reservoir resets, so the collect button is gone.
      assert Players.get_player!().scrip == 15
      refute has_element?(view, "#bleed-collect")
    end

    test "the periodic refresh re-derives the bleed without crashing", %{conn: conn} do
      three_hours_ago =
        DateTime.utc_now() |> DateTime.add(-3 * 3600, :second) |> DateTime.truncate(:second)

      setup_state([
        {:install_module, "latticework_bleed"},
        {:set, :last_collected, three_hours_ago}
      ])

      {:ok, view, _html} = live(conn, ~p"/hideout")

      send(view.pid, :refresh)

      # The reservoir readout still renders after a refresh tick.
      assert has_element?(view, "#bleed-reservoir")
    end

    test "an unexpected dispatch error flashes gracefully instead of crashing" do
      # The collect handler must not fall through on a dispatch error other than
      # :nothing_to_collect (a DB/server failure mid-collect). A mounted LiveView can't reach that
      # branch — its player server stays alive all test — so drive the callback directly with a
      # player_id that has no row and no server, which makes Players.dispatch return
      # {:error, :not_found}. with_log swallows the expected start-failure crash report.
      socket = %Phoenix.LiveView.Socket{assigns: %{__changed__: %{}, player_id: -1, flash: %{}}}

      {result, _log} =
        with_log(fn -> ShuntWeb.HideoutLive.handle_event("collect", %{}, socket) end)

      assert {:noreply, errored} = result
      assert errored.assigns.flash["error"] == "That didn't work."
    end
  end

  describe "modules" do
    test "buying a module installs it and advances the derived tier", %{conn: conn} do
      setup_state([{:scrip, 100}])

      {:ok, view, _html} = live(conn, ~p"/hideout")

      view |> element("#buy-module-stash") |> render_click()

      assert "stash" in Players.get_player!().modules
      assert Players.get_player!().scrip == 60
      assert has_element?(view, "#hideout-tier", "Tenant")
    end

    test "a module above the premises class is shown but not buyable", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/hideout")

      # drop_point needs class 2; at the class-1 squat it is locked, not purchasable.
      assert has_element?(view, "#module-drop_point")
      refute has_element?(view, "#buy-module-drop_point")
    end
  end

  describe "relocation" do
    test "relocating moves the player's premises and keeps them inside the new hideout", %{
      conn: conn
    } do
      setup_state([{:scrip, 1000}, {:cred, 100}])

      {:ok, view, _html} = live(conn, ~p"/hideout")

      view |> element("#relocate-shunt9_cold_store") |> render_click()

      player = Players.get_player!()
      assert player.premises_id == "shunt9_cold_store"
      assert player.location_id == "shunt9_cold_store"
      # still inside (not redirected); now showing the new premises
      assert has_element?(view, "#hideout")
    end
  end
end
