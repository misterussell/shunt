defmodule ShuntWeb.Components.EventTerminal do
  @moduledoc """
  Modal that renders an active location event as a scrolling terminal transcript
  ("hacking panel"). The backdrop dims the full page, but the panel itself is a
  compact, centered popup (~560px wide, NOT full-screen) — it should read like a
  small terminal window floating over the map, not a takeover view. Replaces the
  old in-panel swap in MovementLive: each event step types out into a growing log,
  with the most recent step's choices revealed once typing finishes. Styling lives
  in assets/css/app.css under the `.event-modal-*` / `.event-log-*` classes;
  typing/reveal behavior lives in the `EventTerminal` JS hook
  (assets/js/hooks/event_terminal.js).
  """
  use Phoenix.Component

  alias Phoenix.LiveView.JS

  attr :id, :string, required: true
  attr :event_id, :string, required: true
  attr :title, :string, required: true
  attr :streams, :map, required: true

  def event_modal(assigns) do
    ~H"""
    <div
      id={@id}
      class="event-modal-backdrop"
      phx-remove={JS.hide(transition: {"event-modal-shutdown", "", ""})}
    >
      <div class="event-modal-panel">
        <div class="event-modal-header">
          <span class="section-header-bracket">┌─[ {@title} ]</span>
          <span class="section-header-rule"></span>
          <span class="section-header-secondary">[ ACTIVE ]</span>
          <span class="section-header-bracket">─┐</span>
        </div>
        <div id="event-log" class="event-log" phx-update="stream">
          <div
            :for={{dom_id, entry} <- @streams.event_log}
            id={dom_id}
            class={["event-log-entry", entry.kind == :echo && "event-log-entry--echo"]}
          >
            <%= cond do %>
              <% entry.kind == :step -> %>
                <p
                  id={dom_id <> "-text"}
                  class="event-step-text"
                  phx-hook="EventTerminal"
                  data-text={entry.text}
                >
                </p>
                <div class="event-choices">
                  <button
                    :for={choice <- entry.choices}
                    id={dom_id <> "-choice-" <> String.replace(choice.label, " ", "-")}
                    class="btn-ghost event-choice-button"
                    phx-click="event_choice"
                    phx-value-event_id={@event_id}
                    phx-value-choice={choice.label}
                  >
                    [ {choice.label} ]
                  </button>
                </div>
              <% entry.kind == :reward -> %>
                <p class="event-reward-text">{entry.text}</p>
                <div class="event-choices event-choices--revealed">
                  <button
                    id={dom_id <> "-close"}
                    class="btn-ghost event-choice-button"
                    phx-click="close_event"
                    phx-value-event_id={entry.event_id}
                  >
                    [ Close ]
                  </button>
                </div>
              <% true -> %>
                <p class="event-echo-text">{"> [ #{entry.text} ]"}</p>
            <% end %>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
