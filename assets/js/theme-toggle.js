;(function () {
  var storageKey = "okbayat-theme"
  var button = document.getElementById("theme-toggle")
  if (!button) return

  function updateButton(theme) {
    var dark = theme === "dark"
    button.setAttribute(
      "aria-label",
      dark ? "Switch to light mode" : "Switch to dark mode"
    )
    button.setAttribute("aria-pressed", dark ? "true" : "false")
    button.title = dark ? "Switch to light mode" : "Switch to dark mode"
  }

  button.addEventListener("click", function () {
    var theme = window.jtdTheme === "dark" ? "light" : "dark"
    var stylesheet = document.getElementById("jtd-theme-stylesheet")

    window.jtdTheme = theme
    document.documentElement.setAttribute("data-theme", theme)
    document.documentElement.style.colorScheme = theme

    if (stylesheet) {
      stylesheet.href = "/assets/css/just-the-docs-" + theme + ".css"
    }

    localStorage.setItem(storageKey, theme)
    updateButton(theme)
  })

  updateButton(window.jtdTheme || "light")
})()
