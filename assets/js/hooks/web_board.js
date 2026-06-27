// WebBoard — the investigation board's drag-and-wire surface.
// The hook owns pointer interactions, card transforms, and the SVG wire layer. The LiveView
// stays the source of truth: it renders/destroys cards and sets state classes; the hook reads
// each card's data-x/data-y/data-rumor-id/data-resonant/data-solved and reflects them, then
// reconciles on every server patch via updated().
//
// Two card sources feed the board:
//   * board cards live inside this.el (id="rumor-ID", data-x/data-y) — positioned absolutely.
//   * intake cards live in the #intake-rail sibling (id="intake-ID", no coords) — dragging one
//     onto the board pushes "place_rumor".
//
// Gestures (all coords pushed as clamped fractional strings, which the server parses):
//   * drag a card body   -> "move_rumor" (board card) / "place_rumor" (intake card); a board card
//                           dropped off the surface pushes "return_to_intake".
//   * drag a wire-port    -> on release over another card, "connect" {a, b}.
//   * click a wire        -> "disconnect" {a, b}.
// Solved (locked) cards do not drag, sprout a port, or expose clickable wires.

const SVG_NS = "http://www.w3.org/2000/svg"
const clampUnit = (n) => Math.max(0, Math.min(1, n))

export default {
  mounted() {
    this.reducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)")
    this.boundIntake = new WeakSet()

    // Structural (not aesthetic) layout so the unstyled board is usable; the frontend-design pass
    // owns the real surface. Absolute children need a positioned, sized container.
    this.el.style.position = "relative"
    if (!this.el.style.minHeight) this.el.style.minHeight = "60vh"

    this.svg = document.createElementNS(SVG_NS, "svg")
    this.svg.setAttribute("class", "wire-layer")
    Object.assign(this.svg.style, {
      position: "absolute",
      inset: "0",
      width: "100%",
      height: "100%",
      pointerEvents: "none",
      zIndex: "0"
    })
    this.el.appendChild(this.svg)

    this.el.addEventListener("pointerdown", (e) => this.onPointerDown(e))
    this.onMove = (e) => this.onPointerMove(e)
    this.onUp = (e) => this.onPointerUp(e)
    this.onResize = () => this.redraw()
    window.addEventListener("pointermove", this.onMove)
    window.addEventListener("pointerup", this.onUp)
    window.addEventListener("resize", this.onResize)

    this.bindIntake()
    this.redraw()
  },

  updated() {
    this.bindIntake()
    this.redraw()
  },

  destroyed() {
    window.removeEventListener("pointermove", this.onMove)
    window.removeEventListener("pointerup", this.onUp)
    window.removeEventListener("resize", this.onResize)
  },

  redraw() {
    this.layoutCards()
    this.drawWires()
  },

  // --- layout ------------------------------------------------------------

  layoutCards() {
    this.boardCards().forEach((card) => {
      if (this.drag && card === this.drag.card) return
      card.style.position = "absolute"
      card.style.left = `${parseFloat(card.dataset.x) * 100}%`
      card.style.top = `${parseFloat(card.dataset.y) * 100}%`
      card.style.transform = "translate(-50%, -50%)"
      card.style.zIndex = "1"
      this.ensurePort(card)
    })
  },

  ensurePort(card) {
    if (card.dataset.solved === "true") return
    if (card.querySelector("[data-port]")) return

    const port = document.createElement("div")
    port.dataset.port = ""
    port.className = "wire-port"
    Object.assign(port.style, {
      position: "absolute",
      top: "-6px",
      right: "-6px",
      width: "12px",
      height: "12px",
      borderRadius: "50%",
      background: "#0ff",
      cursor: "crosshair"
    })
    card.appendChild(port)
  },

  drawWires() {
    this.svg.querySelectorAll("[data-wire]").forEach((p) => p.remove())

    const boardRect = this.el.getBoundingClientRect()
    this.wires().forEach(([a, b]) => {
      const from = this.cardCenter(a, boardRect)
      const to = this.cardCenter(b, boardRect)
      if (!from || !to) return

      const line = document.createElementNS(SVG_NS, "line")
      line.setAttribute("data-wire", `${a}|${b}`)
      line.setAttribute("x1", from.x)
      line.setAttribute("y1", from.y)
      line.setAttribute("x2", to.x)
      line.setAttribute("y2", to.y)

      const card = this.card(a)
      const resonant = card && card.dataset.resonant === "true"
      const solved = card && card.dataset.solved === "true"
      line.setAttribute(
        "class",
        ["wire", resonant && "wire--resonant", solved && "wire--solved"].filter(Boolean).join(" ")
      )
      line.style.stroke = solved ? "#666" : resonant ? "#0ff" : "#888"
      line.style.strokeWidth = "2"

      if (!solved) {
        line.style.pointerEvents = "stroke"
        line.style.cursor = "pointer"
        line.addEventListener("click", () => this.pushEvent("disconnect", {a, b}))
      }
      this.svg.appendChild(line)
    })
  },

  // --- pointer routing ---------------------------------------------------

  onPointerDown(e) {
    const port = e.target.closest("[data-port]")
    if (port) {
      e.preventDefault()
      this.startWire(port.closest("[data-rumor-id]"), e)
      return
    }
    const card = e.target.closest("[data-rumor-id]")
    if (card && this.el.contains(card)) {
      e.preventDefault()
      this.startDrag(card, e, false)
    }
  },

  onPointerMove(e) {
    if (this.drag) {
      this.drag.card.style.left = `${e.clientX - this.drag.offX}px`
      this.drag.card.style.top = `${e.clientY - this.drag.offY}px`
      this.drag.card.style.transform = "none"
    } else if (this.wire) {
      this.updateWire(e.clientX, e.clientY)
    }
  },

  onPointerUp(e) {
    if (this.drag) this.endDrag(e)
    else if (this.wire) this.endWire(e)
  },

  // --- card drag ---------------------------------------------------------

  startDrag(card, e, fromIntake) {
    if (card.dataset.solved === "true") return

    const r = card.getBoundingClientRect()
    this.drag = {
      card,
      fromIntake,
      id: card.dataset.rumorId,
      offX: e.clientX - r.left,
      offY: e.clientY - r.top,
      w: r.width,
      h: r.height
    }
    card.style.position = "fixed"
    card.style.zIndex = "1000"
    card.style.transform = "none"
    card.style.left = `${e.clientX - this.drag.offX}px`
    card.style.top = `${e.clientY - this.drag.offY}px`
  },

  endDrag(e) {
    const {card, fromIntake, id, offX, offY, w, h} = this.drag
    this.drag = null

    const boardRect = this.el.getBoundingClientRect()
    const cx = e.clientX - offX + w / 2
    const cy = e.clientY - offY + h / 2
    const overBoard =
      cx >= boardRect.left && cx <= boardRect.right && cy >= boardRect.top && cy <= boardRect.bottom

    if (overBoard) {
      const x = clampUnit((cx - boardRect.left) / boardRect.width)
      const y = clampUnit((cy - boardRect.top) / boardRect.height)
      this.pushEvent(fromIntake ? "place_rumor" : "move_rumor", {
        id,
        x: String(x),
        y: String(y)
      })
    } else if (!fromIntake) {
      this.pushEvent("return_to_intake", {id})
    } else {
      this.resetCard(card)
    }
  },

  resetCard(card) {
    card.style.position = ""
    card.style.zIndex = ""
    card.style.left = ""
    card.style.top = ""
    card.style.transform = ""
  },

  // --- wire drag ---------------------------------------------------------

  startWire(card, e) {
    if (!card || card.dataset.solved === "true") return

    const line = document.createElementNS(SVG_NS, "line")
    line.setAttribute("data-temp-wire", "")
    line.style.stroke = "#0ff"
    line.style.strokeWidth = "2"
    line.style.pointerEvents = "none"
    this.svg.appendChild(line)

    this.wire = {fromId: card.dataset.rumorId, line}
    this.updateWire(e.clientX, e.clientY)
  },

  updateWire(clientX, clientY) {
    const boardRect = this.el.getBoundingClientRect()
    const from = this.cardCenter(this.wire.fromId, boardRect)
    if (!from) return

    this.wire.line.setAttribute("x1", from.x)
    this.wire.line.setAttribute("y1", from.y)
    this.wire.line.setAttribute("x2", clientX - boardRect.left)
    this.wire.line.setAttribute("y2", clientY - boardRect.top)
  },

  endWire(e) {
    const {fromId, line} = this.wire
    this.wire = null
    line.remove()

    const hit = document.elementFromPoint(e.clientX, e.clientY)
    const target = hit && hit.closest("[data-rumor-id]")
    if (target && this.el.contains(target) && target.dataset.rumorId !== fromId) {
      this.pushEvent("connect", {a: fromId, b: target.dataset.rumorId})
    }
  },

  // --- intake ------------------------------------------------------------

  bindIntake() {
    const rail = document.getElementById("intake-rail")
    if (!rail) return

    rail.querySelectorAll("[data-rumor-id]").forEach((card) => {
      if (this.boundIntake.has(card)) return
      this.boundIntake.add(card)
      card.addEventListener("pointerdown", (e) => {
        e.preventDefault()
        this.startDrag(card, e, true)
      })
    })
  },

  // --- helpers -----------------------------------------------------------

  boardCards() {
    return Array.from(this.el.querySelectorAll("[data-rumor-id]"))
  },

  wires() {
    try {
      return JSON.parse(this.el.dataset.wires || "[]")
    } catch {
      return []
    }
  },

  card(id) {
    return this.el.querySelector(`[data-rumor-id="${CSS.escape(id)}"]`)
  },

  cardCenter(id, boardRect) {
    const el = this.card(id)
    if (!el) return null
    const r = el.getBoundingClientRect()
    return {
      x: r.left + r.width / 2 - boardRect.left,
      y: r.top + r.height / 2 - boardRect.top
    }
  }
}
