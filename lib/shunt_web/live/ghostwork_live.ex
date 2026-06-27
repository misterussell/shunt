defmodule ShuntWeb.GhostworkLive do
  @moduledoc """
  The deck: the GHOSTWORK tab is the player's Ghostdeck. Switching here is "jacking
  in". Everything renders filtered by the player's current location_id — what the
  deck can see depends on where the body is (doc "The deck is the interaction
  surface"). Two-column cockpit: main = SCAN feed + NODES; rail = LOADOUT + CODEX.
  The ICE break opens the IceTerminal modal over the page.

  Presentation boundary: this view renders state and dispatches commands. Scan /
  begin_encounter / act / retreat all live in Shunt.Ghostwork and return the
  effects to dispatch (plus, for the encounter, the updated %Encounter{}); this
  view never computes Progress / Trace / outcomes itself.
  """
  use ShuntWeb, :live_view

  alias Shunt.Ghostwork
  alias Shunt.Players
  alias Shunt.Skills.Catalog, as: SkillsCatalog
  alias Shunt.World

  # TODO: mount/3 — like SkillsLive.mount: get player_id + player, fetch the "ghostwork" tree
  #   (SkillsCatalog.fetch!("ghostwork")) for the ladder_track + titles, assign :status nil,
  #   initialize the scan-feed stream (stream(:signal_feed, [])) and :encounter nil, then
  #   assign_deck(player). The route is a single action; no live_action branching.

  # TODO: handle_event("scan", _, socket) — dispatch &Ghostwork.scan(&1, location) for the
  #   current location (World.get_location(player.location_id)). On {:ok, player, meta}, prepend
  #   a signal-feed entry built from meta (meta.text, meta.kind) to the stream and assign_deck;
  #   flash heat events like SkillsLive.flash_heat_event. {:error, :no_lattice} -> no-op.

  # TODO: handle_event("break", %{"node_id" => id}, socket) — fetch the node
  #   (Ghostwork.IceNode.fetch!(id)); dispatch a resolver that calls Ghostwork.begin_encounter(
  #   player, node) and returns {:ok, effects, %{encounter: enc}} (or {:error, reason}). On
  #   success assign :encounter from meta.encounter and assign_deck. On {:error, :hardened} /
  #   {:error, :already_cracked} set :status and don't open the modal.

  # TODO: handle_event("act", %{"action" => action}, socket) — decode action ("probe" -> :probe,
  #   "program:<id>" -> {:program, id}). Dispatch a resolver calling Ghostwork.act(
  #   socket.assigns.encounter, player, action) returning {:ok, effects, %{encounter: enc}} (or
  #   {:error, reason}). Assign :encounter from meta.encounter and assign_deck so banked rewards /
  #   bust heat are reflected. (The encounter struct itself is transient — never persisted.)

  # TODO: handle_event("retreat", _, socket) — Ghostwork.retreat(socket.assigns.encounter)
  #   returns {:ok, enc, []} (no effects); assign the retreated encounter so the modal shows the
  #   walk-clean end state.

  # TODO: handle_event("close_encounter", _, socket) — assign :encounter nil to put the deck
  #   away (close the modal) once the encounter is cracked / busted / retreated.

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} player={@player} active={:ghostwork} status={@status}>
      <%!-- TODO: render the two-column deck cockpit:
        * <Chrome.ladder_track tree={@tree} current_tier={@current_tier} /> (top, like siblings)
        * <ShuntWeb.Components.IceTerminal.ice_modal :if={@encounter} ... /> over the page
        * main column (.ghostwork-page-grid / .ghostwork-main):
            - SCAN section_header + panel: a [ SCAN ] btn (phx-click="scan") and the
              #signal-feed terminal stream (phx-update="stream"), entry id per item, with a
              "hidden only:block" empty state ("> no signal intercepted").
            - NODES section_header + panel: @nodes (from Ghostwork.nodes_at). Each
              #node-<id> shows name + family; :breakable -> [ BREAK ] btn (phx-click="break",
              phx-value-node_id=id); :hardened -> a "HARDENED — cool off" label, no button.
              Empty state when @nodes == [].
        * rail column (.ghostwork-rail):
            - LOADOUT section_header + panel: @programs (Ghostwork.Programs.owned). Each
              #program-<id> shows name + action + progress/trace. Empty -> "NO PROGRAMS LOADED".
            - CODEX section_header + panel: @mastery (Ghostwork.mastery_summary) per family
              (#mastery-<family>: cracks + fog stage label) and @titles (Ghostwork.titles)
              as #title-<tier> rows lit by earned?.
        Styling: add .ghostwork-* classes in assets/css/app.css matching the chrome palette. --%>
      <div id="ghostwork-deck">
        <p>TODO: deck cockpit</p>
      </div>
    </Layouts.app>
    """
  end

  # TODO: assign_deck(socket, player) — assign :player, :current_tier
  #   (SkillsCatalog.current_tier(player, tree)), :nodes (Ghostwork.nodes_at(player,
  #   player.location_id)), :programs (Ghostwork.Programs.owned(player)), :mastery
  #   (Ghostwork.mastery_summary(player)), :titles (Ghostwork.titles(player)).

  # TODO: signal_entry(meta) — build a stream entry %{id: unique_integer, text: meta.text,
  #   kind: meta.kind} for the scan feed (mirrors MovementLive.step_entry/echo_entry).

  # TODO: flash_heat_event(socket, heat_event) — copy SkillsLive.flash_heat_event/2 (nil -> noop;
  #   otherwise put_flash with the heat event's name/flavor/losses).
end
