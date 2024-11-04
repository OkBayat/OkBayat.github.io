window.onload = function () {
  const audio = document.getElementById("audio")
  const playPauseBtn = document.getElementById("play-pause")
  const currentTimeEl = document.getElementById("current-time")
  const durationEl = document.getElementById("duration")
  const progressContainer = document.getElementById("progress-container")
  const progress = document.getElementById("progress")
  const progressThumb = document.getElementById("progress-thumb")
  const volumeContainer = document.querySelector(".volume-container")
  const volumeProgress = document.getElementById("volume-progress")
  const volumeThumb = document.getElementById("volume-thumb")
  const muteUnmuteBtn = document.getElementById("mute-unmute")
  let isDraggingProgress = false
  let isDraggingVolume = false

  playPauseBtn.addEventListener("click", () => {
    if (audio.paused) {
      audio.play()
      playPauseBtn.classList.remove("paused")
      playPauseBtn.classList.add("playing")
    } else {
      audio.pause()
      playPauseBtn.classList.remove("playing")
      playPauseBtn.classList.add("paused")
    }
  })

  audio.addEventListener("timeupdate", () => {
    if (!isDraggingProgress) {
      const currentTime = formatTime(audio.currentTime)
      currentTimeEl.textContent = currentTime

      const progressPercent = (audio.currentTime / audio.duration) * 100
      progress.style.width = `${progressPercent}%`
      progressThumb.style.left = `${progressPercent}%`
    }
  })

  audio.addEventListener("loadedmetadata", () => {
    durationEl.textContent = formatTime(audio.duration)
  })

  function addEventListenersForDrag(element, updateFunction, setDraggingFlag) {
    element.addEventListener("mousedown", (e) => {
      setDraggingFlag(true)
      updateFunction(e)
      window.addEventListener("mousemove", updateFunction)
      window.addEventListener("mouseup", () => {
        setDraggingFlag(false)
        window.removeEventListener("mousemove", updateFunction)
      })
    })

    element.addEventListener("touchstart", (e) => {
      setDraggingFlag(true)
      updateFunction(e.touches[0]);
      function eventListener(event) {
        updateFunction(event.touches[0])
      }
      window.addEventListener("touchmove", eventListener)
      window.addEventListener("touchend", () => {
        setDraggingFlag(false)
        window.removeEventListener("touchmove", eventListener)
      })
    })
  }

  addEventListenersForDrag(
    progressContainer,
    updateProgress,
    (flag) => (isDraggingProgress = flag)
  )
  addEventListenersForDrag(
    volumeContainer,
    updateVolume,
    (flag) => (isDraggingVolume = flag)
  )

  function updateProgress(e) {
    const rect = progressContainer.getBoundingClientRect()
    let offsetX = e.clientX - rect.left
    offsetX = Math.max(0, Math.min(offsetX, rect.width))
    const duration = audio.duration
    const newTime = (offsetX / rect.width) * duration

    if (!isDraggingVolume) {
      audio.currentTime = newTime
    }
    const progressPercent = (newTime / duration) * 100
    progress.style.width = `${progressPercent}%`
    progressThumb.style.left = `${progressPercent}%`
  }

  function updateVolume(e) {
    const rect = volumeContainer.getBoundingClientRect()
    let offsetX = e.clientX - rect.left
    offsetX = Math.max(0, Math.min(offsetX, rect.width))
    const volume = offsetX / rect.width

    audio.volume = volume
    volumeProgress.style.width = `${volume * 100}%`
    volumeThumb.style.left = `${volume * 100}%`
  }

  muteUnmuteBtn.addEventListener("click", () => {
    if (audio.muted) {
      audio.muted = false
      muteUnmuteBtn.classList.remove("muted")
      muteUnmuteBtn.classList.add("unmuted")
    } else {
      audio.muted = true
      muteUnmuteBtn.classList.remove("unmuted")
      muteUnmuteBtn.classList.add("muted")
    }
  })

  function formatTime(time) {
    const minutes = Math.floor(time / 60)
    const seconds = Math.floor(time % 60)
    return `${minutes < 10 ? "0" : ""}${minutes}:${
      seconds < 10 ? "0" : ""
    }${seconds}`
  }
}
