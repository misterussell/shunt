defmodule ShuntWeb.Components.IceTerminal do
  @moduledoc """
  The ICE-break encounter panel: a focused terminal modal over the deck page
  (EventTerminal "hacking panel" pattern, extended with Progress / Trace meters).
  Opening it is breaking ICE; finishing or retreating closes it — you put the deck
  away. Driven entirely by the %Shunt.Ghostwork.Encounter{} in the LiveView assigns;
  it renders state and emits phx-click commands ("act" / "retreat" / "close_encounter")
  that the LiveView dispatches through Shunt.Ghostwork — never recomputing outcomes.

  ## Visual signature

  This panel is the one place Ghostwork spends boldness (the rest of the deck stays
  quiet). Two linked ideas carry it:

    * Trace as a *detection heartbeat* — a segmented gauge filling toward 100,
      cyan -> amber -> red, with a restrained pulse only in the danger zone (>= 85).
    * Fog-of-war as *redaction* — unknown action costs and the layer weakness render
      as ▓ redaction glyphs (reusing the locked-recipe motif) that resolve into real
      values as family mastery rises: Shunt.Ghostwork.numbers_known?/1 un-redacts the
      numbers, weakness_known?/1 un-redacts the tell. "Reading the ICE" made literal.

  Motion respects prefers-reduced-motion (gauge fills instantly, danger pulse off).
  """
  use Phoenix.Component

  alias Phoenix.LiveView.JS
  alias Shunt.Ghostwork

  @trace_segments 20

  # TODO: Replace the single PROGRESS bar with a subroutine board for the current layer.
  # Render one row per subroutine (from the layer's :subroutines), each showing: its name,
  # its threat (:barrier/:sentry/:trap — ALWAYS visible, with a glyph/label), its key
  # (un-redacted only when Ghostwork.weakness_known?/1, else the ▓ redaction motif), and its
  # own mini Progress bar (accumulated from encounter.subroutine_progress over its
  # progress_required). A down subroutine renders done/struck-through. Clicking a row selects
  # it as the target (phx-click "select_target", phx-value-subroutine=<id>); mark the
  # selected row and disable selecting down ones. The TRACE gauge and fog redaction of action
  # numbers stay exactly as they are.

  # TODO: Make the action buttons act on the SELECTED subroutine — add phx-value-subroutine
  # ={@selected_subroutine} to the Probe and program "act" buttons so the LiveView's act/4
  # dispatch knows the target. The action bar lists Probe + the player's equipped loadout
  # (<= 3 programs) passed in via @programs; Retreat/Close unchanged. Consider showing, on
  # each action, whether it MATCHES the selected subroutine's key once keys are known (a
  # match hint), since matched vs mismatched is the core decision.

  attr :id, :string, required: true
  attr :encounter, :map, required: true
  attr :programs, :list, required: true
  # TODO: add `attr :selected_subroutine, :string` (the LiveView-held target id) and thread
  # it through to the board + action buttons.

  def ice_modal(assigns) do
    encounter = assigns.encounter
    layer = Enum.at(encounter.node.layers, encounter.layer_index)

    assigns =
      assigns
      |> assign(:layer, layer)
      |> assign(:layer_count, length(encounter.node.layers))
      |> assign(:numbers_known?, Ghostwork.numbers_known?(encounter))
      |> assign(:weakness_known?, Ghostwork.weakness_known?(encounter))
      |> assign(:probe, Ghostwork.probe_profile())
      |> assign(:trace_lit, lit_segments(encounter.trace))
      |> assign(:segments, 1..@trace_segments)

    ~H"""
    <div
      id={@id}
      class="event-modal-backdrop"
      phx-remove={JS.hide(transition: {"event-modal-shutdown", "", ""})}
    >
      <div class="event-modal-panel ice-terminal-panel">
        <div class="event-modal-header">
          <span class="section-header-bracket">┌─[ {@encounter.node.name} ]</span>
          <span class="section-header-rule"></span>
          <span class={["section-header-secondary", status_accent(@encounter.status)]}>
            [ {status_label(@encounter.status)} ]
          </span>
          <span class="section-header-bracket">─┐</span>
        </div>

        <div class="ice-terminal-body">
          <div class="ice-layer-head">
            <span class="ice-layer-title">
              LAYER {@encounter.layer_index + 1}/{@layer_count} · {@layer.name}
            </span>
            <div class="ice-layer-stack" aria-hidden="true">
              <span
                :for={i <- 0..(@layer_count - 1)}
                class={["ice-layer-pip", pip_class(i, @encounter.layer_index)]}
              />
            </div>
          </div>

          <div class="ice-meters">
            <div class="ice-meter">
              <span class="ice-meter-label">PROGRESS</span>
              <div class="ice-meter-track">
                <div
                  id="ice-progress"
                  class="ice-meter-fill ice-meter-fill--progress"
                  style={"width: #{Shunt.Ghostwork.progress_percent(@encounter.progress, @layer.progress_required)}%"}
                >
                </div>
              </div>
              <span class="ice-meter-readout">
                {@encounter.progress} / {@layer.progress_required}
              </span>
            </div>

            <div class="ice-meter">
              <span class="ice-meter-label">TRACE</span>
              <div
                id="ice-trace"
                class={["ice-trace-gauge", @encounter.trace >= 85 && "ice-trace-gauge--danger"]}
                role="meter"
                aria-valuenow={@encounter.trace}
                aria-valuemin="0"
                aria-valuemax="100"
              >
                <span
                  :for={seg <- @segments}
                  class={["ice-trace-seg", seg_class(seg, @trace_lit)]}
                />
              </div>
              <span class="ice-meter-readout ice-meter-readout--trace">{@encounter.trace} / 100</span>
            </div>

            <p class="ice-weakness">
              weakness:
              <%= if @weakness_known? do %>
                <span class="ice-weakness-tell">{weakness_text(@layer.weakness)}</span>
              <% else %>
                <span class="ice-redact ice-redact--wide">▓▓▓▓▓</span>
              <% end %>
            </p>
          </div>

          <%= if @encounter.status == :active do %>
            <div class="ice-actions">
              <button id="ice-probe" class="ice-action" phx-click="act" phx-value-action="probe">
                <span class="ice-action-name">PROBE</span>
                <.cost known={@numbers_known?} progress={@probe.progress} trace={@probe.trace} />
              </button>
              <button
                :for={prog <- @programs}
                id={"ice-program-#{prog.id}"}
                class="ice-action"
                phx-click="act"
                phx-value-action={"program:" <> prog.id}
              >
                <span class="ice-action-name">{prog.name}</span>
                <.cost known={@numbers_known?} progress={prog.progress} trace={prog.trace} />
              </button>
              <button id="ice-retreat" class="ice-action ice-action--retreat" phx-click="retreat">
                <span class="ice-action-name">RETREAT</span>
                <span class="ice-action-hint">walk clean</span>
              </button>
            </div>
          <% else %>
            <div class="ice-actions ice-actions--end">
              <p class={["ice-end-line", status_accent(@encounter.status)]}>
                {end_line(@encounter.status)}
              </p>
              <button id="ice-close" class="ice-action" phx-click="close_encounter">
                <span class="ice-action-name">CLOSE</span>
              </button>
            </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  attr :known, :boolean, required: true
  attr :progress, :integer, required: true
  attr :trace, :integer, required: true

  defp cost(assigns) do
    ~H"""
    <span class="ice-action-cost">
      <%= if @known do %>
        +{@progress}P · {@trace}T
      <% else %>
        +<span class="ice-redact">▓</span>P · <span class="ice-redact">▓</span>T
      <% end %>
    </span>
    """
  end

  defp lit_segments(trace) do
    trace |> Kernel./(5) |> ceil() |> min(@trace_segments)
  end

  # A segment is "high"/"mid" by the Trace value at its top edge (seg * 5).
  defp seg_class(seg, lit) when seg > lit, do: "ice-trace-seg--dim"
  defp seg_class(seg, _lit) when seg * 5 >= 85, do: "ice-trace-seg--high"
  defp seg_class(seg, _lit) when seg * 5 >= 60, do: "ice-trace-seg--mid"
  defp seg_class(_seg, _lit), do: "ice-trace-seg--low"

  defp pip_class(index, current) when index < current, do: "ice-layer-pip--done"
  defp pip_class(index, current) when index == current, do: "ice-layer-pip--current"
  defp pip_class(_index, _current), do: "ice-layer-pip--next"

  defp status_label(:active), do: "BREAKING"
  defp status_label(:cracked), do: "CRACKED"
  defp status_label(:busted), do: "BUSTED"
  defp status_label(:retreated), do: "CLEAN EXIT"

  defp status_accent(:busted), do: "ice-accent--danger"
  defp status_accent(:cracked), do: "ice-accent--good"
  defp status_accent(_status), do: nil

  defp end_line(:cracked), do: "Node owned. Data banked."
  defp end_line(:busted), do: "Trace maxed — connection burned. Node hardened."
  defp end_line(:retreated), do: "Pulled out clean. Banked layers kept."

  defp weakness_text(nil), do: "none"
  defp weakness_text(action), do: to_string(action)
end
