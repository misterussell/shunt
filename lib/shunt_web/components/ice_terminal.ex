defmodule ShuntWeb.Components.IceTerminal do
  @moduledoc """
  The ICE-break encounter panel: a focused terminal modal over the deck page
  (EventTerminal "hacking panel" pattern, extended with Progress / Trace meters).
  Opening it is breaking ICE; finishing or retreating closes it — you put the deck
  away. Driven entirely by the %Shunt.Ghostwork.Encounter{} in the LiveView assigns;
  it renders state and emits phx-click commands ("act" / "retreat" / "close_encounter")
  that the LiveView dispatches through Shunt.Ghostwork — never recomputing outcomes.

  Mastery fog-of-war (doc "Mastery fog-of-war"): Shunt.Ghostwork.numbers_known?/1 and
  weakness_known?/1 decide whether action Progress/Trace numbers and the layer's
  weakness tell are shown or rendered as "?".
  """
  use Phoenix.Component

  alias Phoenix.LiveView.JS
  alias Shunt.Ghostwork

  attr :id, :string, required: true
  attr :encounter, :map, required: true
  attr :programs, :list, required: true

  def ice_modal(assigns) do
    encounter = assigns.encounter
    layer = Enum.at(encounter.node.layers, encounter.layer_index)

    assigns =
      assigns
      |> assign(:layer, layer)
      |> assign(:numbers_known?, Ghostwork.numbers_known?(encounter))
      |> assign(:weakness_known?, Ghostwork.weakness_known?(encounter))
      |> assign(:probe, Ghostwork.probe_profile())

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
          <span class="section-header-secondary">[ {status_label(@encounter.status)} ]</span>
          <span class="section-header-bracket">─┐</span>
        </div>

        <div class="ice-terminal-body">
          <div class="ice-meters">
            <div class="ice-meter">
              <span class="ice-meter-label">LAYER · {@layer.name}</span>
              <div class="ice-meter-track">
                <div
                  id="ice-progress"
                  class="ice-meter-fill ice-meter-fill--progress"
                  style={bar_style(@encounter.progress, @layer.progress_required)}
                >
                </div>
              </div>
              <span class="ice-meter-readout">
                {@encounter.progress} / {@layer.progress_required}
              </span>
            </div>

            <div class="ice-meter">
              <span class="ice-meter-label">TRACE</span>
              <div class="ice-meter-track">
                <div
                  id="ice-trace"
                  class={["ice-meter-fill", trace_class(@encounter.trace)]}
                  style={bar_style(@encounter.trace, 100)}
                >
                </div>
              </div>
              <span class="ice-meter-readout">{@encounter.trace} / 100</span>
            </div>

            <p class="ice-weakness">
              weakness: {if @weakness_known?, do: weakness_text(@layer.weakness), else: "?"}
            </p>
          </div>

          <%= if @encounter.status == :active do %>
            <div class="ice-actions">
              <button
                id="ice-probe"
                class="btn-primary ice-action"
                phx-click="act"
                phx-value-action="probe"
              >
                [ PROBE ] {action_stats(@numbers_known?, @probe.progress, @probe.trace)}
              </button>
              <button
                :for={prog <- @programs}
                id={"ice-program-#{prog.id}"}
                class="btn-ghost ice-action"
                phx-click="act"
                phx-value-action={"program:" <> prog.id}
              >
                [ {prog.name} ] {action_stats(@numbers_known?, prog.progress, prog.trace)}
              </button>
              <button id="ice-retreat" class="btn-ghost ice-action" phx-click="retreat">
                [ RETREAT ]
              </button>
            </div>
          <% else %>
            <div class="ice-actions ice-actions--end">
              <p class="ice-end-line">{end_line(@encounter.status)}</p>
              <button id="ice-close" class="btn-ghost ice-action" phx-click="close_encounter">
                [ CLOSE ]
              </button>
            </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  defp status_label(:active), do: "BREAKING"
  defp status_label(:cracked), do: "CRACKED"
  defp status_label(:busted), do: "BUSTED"
  defp status_label(:retreated), do: "CLEAN EXIT"

  defp end_line(:cracked), do: "Node owned. Data banked."
  defp end_line(:busted), do: "Trace maxed — connection burned. Node hardened."
  defp end_line(:retreated), do: "Pulled out clean. Banked layers kept."

  defp bar_style(value, max) do
    percent = if max > 0, do: min(100, round(value / max * 100)), else: 0
    "width: #{percent}%"
  end

  defp trace_class(trace) when trace >= 85, do: "ice-meter-fill--trace-high"
  defp trace_class(trace) when trace >= 60, do: "ice-meter-fill--trace-mid"
  defp trace_class(_trace), do: "ice-meter-fill--trace-low"

  defp weakness_text(nil), do: "none"
  defp weakness_text(action), do: to_string(action)

  defp action_stats(false, _progress, _trace), do: "?"
  defp action_stats(true, progress, trace), do: "P#{progress} / T#{trace}"
end
