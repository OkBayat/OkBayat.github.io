(function () {
  var storageKey = "okbayat-theme"
  var button = document.getElementById("theme-toggle")
  var script = document.currentScript
  var themeBase =
    script && script.dataset.themeBase
      ? script.dataset.themeBase
      : "/assets/css/just-the-docs-"

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

  function saveTheme(theme) {
    try {
      window.localStorage.setItem(storageKey, theme)
    } catch (error) {
      // The selected theme still applies for the current page.
    }
  }

  function applyTheme(theme) {
    var stylesheet = document.getElementById("jtd-theme-stylesheet")

    window.jtdTheme = theme
    document.documentElement.setAttribute("data-theme", theme)
    document.documentElement.style.colorScheme = theme

    if (stylesheet) {
      stylesheet.setAttribute("href", themeBase + theme + ".css")
    }

    saveTheme(theme)
    updateButton(theme)
  }

  updateButton(window.jtdTheme === "dark" ? "dark" : "light")

  button.addEventListener("click", function () {
    applyTheme(window.jtdTheme === "dark" ? "light" : "dark")
  })
})()
