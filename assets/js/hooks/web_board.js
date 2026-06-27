// WebBoard — the investigation board's drag-and-wire surface.
// The hook owns pointer interactions, card transforms, and the SVG wire layer. The LiveView
// stays the source of truth: it renders/destroys cards and sets state classes; the hook reads
// each card's data-x/data-y/data-rumor-id/data-resonant/data-solved and reflects them, then
// reconciles on every server patch via updated().
//
// TODO: mounted()
//   - create the SVG wire layer in JS and append it to this.el (never rendered in HEEx, so
//     morphdom won't fight it). drawWires() reads this.el's cards + the wires payload.
//   - layoutCards(): position each [data-rumor-id] card from its fractional data-x/data-y
//     relative to this.el's bounding box.
//   - bind pointer handlers (pointerdown/move/up) for two gestures:
//       * drag a card body -> live transform; on drop push "move_rumor" (or "place_rumor" when
//         the card came from the intake rail) with clamped fractional {id, x, y}.
//       * drag from a card's wire-port to another card -> on release over a target push
//         "connect" {a, b}; a release on empty space cancels.
//   - while dragging, redraw the affected wire(s) each frame so they track the card.
//   - guard motion with prefers-reduced-motion; respect data-solved (no drag/disconnect on
//     locked cards).
//
// TODO: updated()
//   - re-run layoutCards() and drawWires() so server-added cards (new rumors), repositions, new
//     wires, resonance, and solved/locked state all reconcile after a LiveView patch.
//
// TODO: drawWires()
//   - render one SVG path per wire between its two cards' centers. Apply state from the cards:
//     idle vs data-resonant (cluster surge) vs data-solved (locked/desaturated). Styling itself
//     lands in the frontend-design pass; this hook just sets the classes/endpoints.
export default {
  mounted() {
    // TODO: see file header.
  },

  updated() {
    // TODO: see file header.
  }
}
