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

  attr :id, :string, required: true
  attr :encounter, :map, required: true
  attr :programs, :list, required: true

  def ice_modal(assigns) do
    # TODO: render the encounter modal (reuse .event-modal-backdrop / .event-modal-panel and add
    #   .ice-terminal-* classes in app.css):
    #   * header: node name + "[ BREAKING ]" (active) / "[ CRACKED ]" / "[ BUSTED ]" /
    #     "[ CLEAN EXIT ]" from @encounter.status.
    #   * meters: current layer (Enum.at(@encounter.node.layers, @encounter.layer_index)) name +
    #     a Progress bar (@encounter.progress / layer.progress_required) and a Trace bar
    #     (@encounter.trace / 100, ramping cyan -> amber -> red like wallet Heat).
    #   * weakness tell: show layer.weakness only when Ghostwork.weakness_known?(@encounter);
    #     otherwise "weakness: ?".
    #   * actions (only when status == :active):
    #       - [ PROBE ] -> phx-click="act" phx-value-action="probe". Show its Progress/Trace
    #         (@probe constants) only when Ghostwork.numbers_known?(@encounter), else "?".
    #       - one button per program in @programs: phx-click="act"
    #         phx-value-action={"program:" <> prog.id}; show prog numbers gated on numbers_known?.
    #       - [ RETREAT ] -> phx-click="retreat".
    #   * end state (status != :active): a [ CLOSE ] button -> phx-click="close_encounter".
    #   Give each control a stable DOM id (e.g. id="ice-probe", id={"ice-program-" <> prog.id},
    #   id="ice-retreat", id="ice-close") for LiveView tests.
    ~H"""
    <div id={@id} class="event-modal-backdrop" phx-remove={JS.hide()}>
      <div class="event-modal-panel">
        <p>TODO: ICE terminal — status {@encounter.status}</p>
      </div>
    </div>
    """
  end
end
