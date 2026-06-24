defmodule ShuntWeb.Components.EventTerminal do
  @moduledoc """
  Full-screen modal that renders an active location event as a scrolling terminal
  transcript ("hacking panel"). Replaces the old in-panel swap in MovementLive: each
  event step types out into a growing log, with the most recent step's choices
  revealed once typing finishes. Styling lives in assets/css/app.css under the
  `.event-modal-*` / `.event-log-*` classes; typing/reveal behavior lives in the
  `EventTerminal` JS hook (assets/js/hooks/event_terminal.js).
  """
  use Phoenix.Component

  # TODO: implement `event_modal/1`, rendered from MovementLive only when
  # @active_event_id is set:
  #
  #   <EventTerminal.event_modal
  #     id="event-modal"
  #     event_id={@active_event_id}
  #     title={Events.get!(@active_event_id).title}
  #     streams={@streams}
  #   />
  #
  # attrs: `id` (string, required), `event_id` (string, required — used for
  # phx-value-event_id on choice buttons), `title` (string, required), `streams`
  # (map, required — the parent's @streams, so this component can render
  # @streams.event_log).
  #
  # Markup:
  # - Outer `<div id={@id} class="event-modal-backdrop">` wrapping an inner
  #   `<div class="event-modal-panel">` (reuse the `.panel` look — see
  #   ShuntWeb.Chrome.panel/1 for the pattern this class list follows).
  # - `phx-remove={Phoenix.LiveView.JS.hide(transition: {"event-modal-shutdown", "", ""})}`
  #   on the backdrop div, so closing (when @active_event_id -> nil removes this
  #   component from the tree) plays a brief shutdown flicker instead of vanishing
  #   instantly. The boot-up flicker on open needs no JS — it's a plain CSS
  #   `animation: terminal-boot ...` on `.event-modal-panel` that plays automatically
  #   when the backdrop mounts.
  # - Header: reuse the bracket motif from ShuntWeb.Chrome.section_header/1
  #   (`┌─[ TITLE ]───[ ACTIVE ]─┐`), showing `@title` uppercased.
  # - Body: `<div id="event-log" class="event-log" phx-update="stream">` containing:
  #
  #     <div
  #       :for={{dom_id, entry} <- @streams.event_log}
  #       id={dom_id}
  #       class={["event-log-entry", entry.kind == :echo && "event-log-entry--echo"]}
  #     >
  #       <%= if entry.kind == :step do %>
  #         <p
  #           id={dom_id <> "-text"}
  #           class="event-step-text"
  #           phx-hook="EventTerminal"
  #           data-text={entry.text}
  #         ></p>
  #         <div class="event-choices">
  #           <button
  #             :for={choice <- entry.choices}
  #             id={dom_id <> "-choice-" <> String.replace(choice.label, " ", "-")}
  #             class="btn-ghost event-choice-button"
  #             phx-click="event_choice"
  #             phx-value-event_id={@event_id}
  #             phx-value-choice={choice.label}
  #           >
  #             [ {choice.label} ]
  #           </button>
  #         </div>
  #       <% else %>
  #         <p class="event-echo-text">&gt; [ {entry.text} ]</p>
  #       <% end %>
  #     </div>
  #
  #   Leave the `.event-step-text` `<p>` empty in the markup — the JS hook owns typing
  #   the text into it client-side, reading it back from `data-text`.
  # - Only the last entry's `.event-choices` should ever be interactive/visible — that's
  #   handled in CSS via `:last-child` (see TODO in assets/css/app.css), not here.
end
