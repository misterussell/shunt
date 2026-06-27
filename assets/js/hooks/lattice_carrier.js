// LatticeCarrier — the Ghostwork deck's signature element.
// The carrier <svg> trace ambient-drifts via CSS (a quiet "listening" hum). This hook adds
// the one-shot amplitude BURST on scan: the server pushes "lattice:pulse" after a successful
// scan and we animate the trace imperatively (Web Animations API, so morphdom can't clobber
// a transient class), guarded by prefers-reduced-motion.
export default {
  mounted() {
    this.reducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)")
    this.handleEvent("lattice:pulse", () => this.burst())
  },

  burst() {
    if (this.reducedMotion.matches) return
    if (this.el.classList.contains("lattice-carrier--flat")) return

    const trace = this.el.querySelector(".lattice-carrier-trace")
    if (!trace) return

    trace.animate(
      [
        {transform: "scaleY(1)", opacity: 1},
        {transform: "scaleY(2.6)", opacity: 1, offset: 0.25},
        {transform: "scaleY(1)", opacity: 1}
      ],
      {duration: 700, easing: "cubic-bezier(0.2, 0.8, 0.2, 1)"}
    )
  }
}
