(function () {
  var storageKey = "okbayat-theme";
  var button = document.getElementById("theme-toggle");

  function updateButton(theme) {
    if (!button) return;
    var dark = theme === "dark";
    button.setAttribute("aria-label", dark ? "Switch to light mode" : "Switch to dark mode");
    button.setAttribute("aria-pressed", dark ? "true" : "false");
    button.title = dark ? "Switch to light mode" : "Switch to dark mode";
  }

  function applyTheme(theme) {
    var stylesheet = document.getElementById("jtd-theme-stylesheet");
    window.jtdTheme = theme;
    document.documentElement.setAttribute("data-theme", theme);
    document.documentElement.style.colorScheme = theme;

    if (stylesheet) {
      stylesheet.href = "/assets/css/just-the-docs-" + theme + ".css";
    }

    try {
      window.localStorage.setItem(storageKey, theme);
    } catch (error) {}

    updateButton(theme);
  }

  if (!button) return;

  updateButton(window.jtdTheme === "dark" ? "dark" : "light");

  button.addEventListener("click", function () {
    applyTheme(window.jtdTheme === "dark" ? "light" : "dark");
  });
})();
