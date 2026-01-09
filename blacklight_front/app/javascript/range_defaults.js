function setRangeDefaults() {
  const DEFAULT_BEGIN = '1920'
  const DEFAULT_END = new Date().getFullYear().toString()
  
  document.querySelectorAll('input[name^="range["][name$="[begin]"]').forEach(input => {
    if (!input.dataset.defaultSet) {
      input.value = DEFAULT_BEGIN
      input.dataset.defaultSet = 'true'
    }
  })
  
  document.querySelectorAll('input[name^="range["][name$="[end]"]').forEach(input => {
    if (!input.dataset.defaultSet) {
      input.value = DEFAULT_END
      input.dataset.defaultSet = 'true'
    }
  })
}

// Watch for the facet sidebar to be added/updated
const observer = new MutationObserver((mutations) => {
  // Check if any range inputs were added
  const hasRangeInputs = document.querySelector('input[name^="range["]')
  if (hasRangeInputs) {
    setRangeDefaults()
  }
})

// Start observing when Turbo loads
document.addEventListener('turbo:load', () => {
  // Run immediately first
  setTimeout(setRangeDefaults, 100) // faster
  
  // Then watch for changes
  const sidebar = document.querySelector('#sidebar') || document.querySelector('.blacklight-facets') || document.body
  observer.observe(sidebar, {
    childList: true,
    subtree: true
  })
})

// Cleanup observer when navigating away
document.addEventListener('turbo:before-cache', () => {
  observer.disconnect()
})