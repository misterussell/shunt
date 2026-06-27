// LatticeCarrier — the Ghostwork deck's signature element.
// The carrier <svg> trace ambient-drifts via CSS (a quiet "listening" hum). This hook adds
// the one-shot amplitude BURST on scan: the server pushes "lattice:pulse" after a successful
// scan and we animate the trace imperatively (Web Animations API, so morphdom can't clobber
// a transient class), guarded by prefers-reduced-motion.
export default {
  mounted() {
    // TODO: handleEvent("lattice:pulse", ...) -> if prefers-reduced-motion is "no-preference",
    // run a brief amplitude burst on the .lattice-carrier-trace element via el.animate(...)
    // (e.g. transform: scaleY(1) -> scaleY(~2.4) -> scaleY(1) over ~700ms, transform-origin
    // center). Do nothing when reduced motion is preferred. No-op if the carrier is flatlined
    // (.lattice-carrier--flat present).
  }
}
