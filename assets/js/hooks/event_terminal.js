export default {
  // TODO: implement the EventTerminal hook, attached via `phx-hook="EventTerminal"`
  // on each :step entry's <p class="event-step-text" data-text="..."> node (see
  // lib/shunt_web/components/event_terminal.ex).
  //
  // mounted():
  // - Read the full step text from `this.el.dataset.text`.
  // - Type it into `this.el.textContent` one character at a time on a ~18ms interval
  //   (store the interval id on `this` so destroyed() can clear it if the entry is
  //   removed mid-type, e.g. fast navigation away from the page).
  // - After each character append, scroll the transcript container to the bottom so
  //   the actively-typing line stays in view:
  //     const log = this.el.closest("#event-log")
  //     log.scrollTop = log.scrollHeight
  // - When typing finishes (interval cleared): find this entry's choices block —
  //     this.el.closest(".event-log-entry").querySelector(".event-choices")
  //   — and add the `event-choices--revealed` class to it (CSS handles the fade-in
  //   transition and the `:last-child` visibility rule).
  //
  // destroyed():
  // - Clear the typing interval if it's still running.
}
