(() => {
  const initializeTimeline = (explorer) => {
    const timeline = explorer.querySelector("[data-timeline-list]")
    const items = [...explorer.querySelectorAll("[data-timeline-item]")]
    const search = explorer.querySelector("[data-timeline-search]")
    const language = explorer.querySelector("[data-timeline-language]")
    const sort = explorer.querySelector("[data-timeline-sort]")
    const resultCount = explorer.querySelector("[data-timeline-result-count]")
    const emptyState = explorer.querySelector("[data-timeline-empty]")
    const reset = explorer.querySelector("[data-timeline-reset]")
    const typeChips = [
      ...explorer.querySelectorAll("[data-timeline-type-chips] [data-filter-value]"),
    ]
    const topicChips = [
      ...explorer.querySelectorAll("[data-timeline-topic-chips] [data-filter-value]"),
    ]

    if (
      !timeline ||
      !search ||
      !language ||
      !sort ||
      !resultCount ||
      !emptyState ||
      !reset
    ) {
      return
    }

    let selectedType = "all"
    let selectedTopic = "all"

    const chooseChip = (chips, selectedChip) => {
      chips.forEach((chip) => {
        chip.setAttribute("aria-pressed", String(chip === selectedChip))
      })
    }

    const dataTokens = (value) => value.split(/\s+/).filter(Boolean)

    const itemTopics = (item) => dataTokens(item.dataset.topic)
    const itemLanguages = (item) => dataTokens(item.dataset.lang)

    const prepareChips = () => {
      typeChips.forEach((chip) => {
        if (chip.dataset.filterValue === "all") return

        chip.hidden = !items.some(
          (item) => item.dataset.type === chip.dataset.filterValue
        )
      })

      topicChips.forEach((chip) => {
        if (chip.dataset.filterValue === "all") return

        chip.hidden = !items.some((item) =>
          itemTopics(item).includes(chip.dataset.filterValue)
        )
      })
    }

    const sortItems = () => {
      const direction = sort.value === "newest" ? -1 : 1

      items
        .slice()
        .sort(
          (left, right) =>
            left.dataset.date.localeCompare(right.dataset.date) * direction
        )
        .forEach((item) => timeline.appendChild(item))
    }

    const applyFilters = () => {
      const query = search.value.trim().toLocaleLowerCase()
      let visible = 0

      items.forEach((item) => {
        const typeMatch =
          selectedType === "all" || item.dataset.type === selectedType
        const topicMatch =
          selectedTopic === "all" || itemTopics(item).includes(selectedTopic)
        const languageMatch =
          language.value === "all" ||
          itemLanguages(item).includes(language.value)
        const searchableText = `${item.dataset.search} ${item.textContent}`
          .toLocaleLowerCase()
          .replace(/\s+/g, " ")
        const searchMatch = !query || searchableText.includes(query)
        const show = typeMatch && topicMatch && languageMatch && searchMatch

        item.hidden = !show
        if (show) visible += 1
      })

      resultCount.textContent = `${visible} ${visible === 1 ? "entry" : "entries"} shown`
      emptyState.hidden = visible !== 0
    }

    typeChips.forEach((chip) => {
      chip.addEventListener("click", () => {
        selectedType = chip.dataset.filterValue
        chooseChip(typeChips, chip)
        applyFilters()
      })
    })

    topicChips.forEach((chip) => {
      chip.addEventListener("click", () => {
        selectedTopic = chip.dataset.filterValue
        chooseChip(topicChips, chip)
        applyFilters()
      })
    })

    explorer.querySelectorAll("[data-timeline-tag]").forEach((button) => {
      button.addEventListener("click", () => {
        search.value = button.dataset.timelineTag
        applyFilters()
        search.focus()
      })
    })

    search.addEventListener("input", applyFilters)
    language.addEventListener("change", applyFilters)
    sort.addEventListener("change", () => {
      sortItems()
      applyFilters()
    })

    reset.addEventListener("click", () => {
      selectedType = "all"
      selectedTopic = "all"
      search.value = ""
      language.value = "all"
      sort.value = "newest"
      chooseChip(typeChips, typeChips[0])
      chooseChip(topicChips, topicChips[0])
      sortItems()
      applyFilters()
      search.focus()
    })

    prepareChips()
    sortItems()
    applyFilters()
  }

  const initializeAllTimelines = () => {
    document
      .querySelectorAll("[data-timeline-explorer]")
      .forEach(initializeTimeline)
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", initializeAllTimelines)
  } else {
    initializeAllTimelines()
  }
})()
