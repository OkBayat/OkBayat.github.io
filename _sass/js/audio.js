const audio = document.getElementById("audio")
const playPauseBtn = document.getElementById("playPause")
const progress = document.getElementById("progress")
const currentTimeDisplay = document.getElementById("currentTime")
const durationDisplay = document.getElementById("duration")
const volumeControl = document.getElementById("volume")

playPauseBtn.addEventListener("click", () => {
  if (audio.paused) {
    audio.play()
    playPauseBtn.classList.add("playing")
  } else {
    audio.pause()
    playPauseBtn.classList.remove("playing")
  }
})

audio.addEventListener("timeupdate", () => {
  const currentTime = audio.currentTime
  const duration = audio.duration
  progress.value = (currentTime / duration) * 100
  currentTimeDisplay.textContent = formatTime(currentTime)
  durationDisplay.textContent = formatTime(duration)
})

progress.addEventListener("input", () => {
  const duration = audio.duration
  audio.currentTime = (progress.value / 100) * duration
})

volumeControl.addEventListener("input", () => {
  audio.volume = volumeControl.value
})

function formatTime(seconds) {
  const minutes = Math.floor(seconds / 60)
  const secs = Math.floor(seconds % 60)
    .toString()
    .padStart(2, "0")
  return `${minutes}:${secs}`
}
