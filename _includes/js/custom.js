function closestNavExpander(target, siteNav) {
  while (target && target !== siteNav) {
    if (target.classList && target.classList.contains("nav-list-expander")) {
      return target
    }

    target = target.parentNode
  }

  return null
}

function collapseNavBranch(navItem) {
  navItem.classList.remove("active")

  var activeItems = navItem.querySelectorAll(".nav-list-item.active")
  for (var i = 0; i < activeItems.length; i++) {
    activeItems[i].classList.remove("active")
  }

  var expanders = navItem.querySelectorAll(".nav-list-expander")
  for (var j = 0; j < expanders.length; j++) {
    expanders[j].setAttribute("aria-pressed", "false")
  }
}

function closeSiblingNavBranches(navItem) {
  if (!navItem.parentNode) {
    return
  }

  var siblings = navItem.parentNode.children
  for (var i = 0; i < siblings.length; i++) {
    var sibling = siblings[i]

    if (
      sibling !== navItem &&
      sibling.classList &&
      sibling.classList.contains("nav-list-item")
    ) {
      collapseNavBranch(sibling)
    }
  }
}

function primaryNavigationHref(pathname) {
  if (pathname === "/") {
    return "/"
  }

  if (pathname === "/about" || pathname.indexOf("/about/") === 0) {
    return "/about"
  }

  if (pathname === "/work" || pathname.indexOf("/work/") === 0) {
    return "/work"
  }

  if (
    pathname === "/research-practice" ||
    pathname.indexOf("/research-practice/") === 0
  ) {
    return "/research-practice"
  }

  if (pathname === "/writing" || pathname.indexOf("/writing/") === 0) {
    return "/writing"
  }

  if (pathname === "/contact" || pathname.indexOf("/contact/") === 0) {
    return "/contact"
  }

  return null
}

// Keep the mobile navigation compact: opening a branch closes its sibling
// branches at the same level. Desktop navigation retains the theme's normal
// multi-branch behavior.
jtd.onReady(function () {
  var siteNav = document.getElementById("site-nav")
  var menuButton = document.getElementById("menu-button")
  var backToTop = document.getElementById("back-to-top")

  if (!siteNav || !menuButton) {
    return
  }

  function mobileNavigationIsAvailable() {
    return window.getComputedStyle(menuButton).display !== "none"
  }

  function syncBackToTopVisibility() {
    if (!backToTop) {
      return
    }

    backToTop.hidden =
      mobileNavigationIsAvailable() && menuButton.classList.contains("nav-open")
  }

  jtd.addEvent(siteNav, "click", function (event) {
    var expander = closestNavExpander(event.target, siteNav)

    if (!expander || !mobileNavigationIsAvailable()) {
      return
    }

    var navItem = expander.parentNode
    var branchWillOpen = !navItem.classList.contains("active")

    if (branchWillOpen) {
      closeSiblingNavBranches(navItem)
    }
  })

  // The theme's menu handler runs first and updates `nav-open`; this listener
  // then mirrors that state onto the Back to top control.
  jtd.addEvent(menuButton, "click", syncBackToTopVisibility)
  jtd.addEvent(window, "resize", syncBackToTopVisibility)
  syncBackToTopVisibility()
})

// Detailed pages are intentionally absent from the global menu. Keep visitors
// oriented by activating the durable hub that owns the current route.
jtd.onReady(function () {
  var pathname = document.location.pathname.replace(/\/+$/, "") || "/"
  var hubHref = primaryNavigationHref(pathname)

  if (!hubHref) {
    return
  }

  var hubLink = document.querySelector(
    '#site-nav .nav-list-link[href="' + hubHref + '"]'
  )

  if (!hubLink) {
    return
  }

  hubLink.classList.add("active")
  if (
    hubLink.parentNode &&
    hubLink.parentNode.classList.contains("nav-list-item")
  ) {
    hubLink.parentNode.classList.add("active")
  }
})

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
