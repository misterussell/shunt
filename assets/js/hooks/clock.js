const format = (date) =>
  date.toLocaleTimeString("en-GB", {hour: "2-digit", minute: "2-digit", second: "2-digit"})

export default {
  mounted() {
    this.el.textContent = format(new Date())
    this.timer = setInterval(() => {
      this.el.textContent = format(new Date())
    }, 1000)
  },
  destroyed() {
    clearInterval(this.timer)
  },
}
