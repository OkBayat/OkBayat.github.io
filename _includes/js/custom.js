// When a language switch is the current URL, Just the Docs activates that
// small switch link. Mirror the active state onto the article's primary
// navigation link so the whole row is selected consistently.
jtd.onReady(function () {
  var activeLanguageLink = document.querySelector(
    "#site-nav .nav-list-language-link.active"
  )

  if (!activeLanguageLink) {
    return
  }

  var primaryLink = activeLanguageLink.previousElementSibling

  if (primaryLink && primaryLink.classList.contains("nav-list-link")) {
    primaryLink.classList.add("active")
  }
})
