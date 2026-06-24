export default {
  mounted() {
    const text = this.el.dataset.text
    const log = this.el.closest("#event-log")
    let i = 0

    this.interval = setInterval(() => {
      i += 1
      this.el.textContent = text.slice(0, i)
      log.scrollTop = log.scrollHeight

      if (i >= text.length) {
        clearInterval(this.interval)
        const choices = this.el.closest(".event-log-entry").querySelector(".event-choices")
        choices && choices.classList.add("event-choices--revealed")
      }
    }, 18)
  },

  destroyed() {
    clearInterval(this.interval)
  }
}
