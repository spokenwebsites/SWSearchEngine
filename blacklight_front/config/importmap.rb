# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin_all_from "app/javascript/controllers", under: "controllers"
pin "@github/auto-complete-element", to: "https://cdn.jsdelivr.net/npm/@github/auto-complete-element@2.0.0/dist/index.esm.js"
pin "@popperjs/core", to: "https://cdn.jsdelivr.net/npm/@popperjs/core@2.11.6/dist/esm/popper.min.js"
pin "bootstrap", to: "https://cdn.jsdelivr.net/npm/bootstrap@5.2.2/dist/js/bootstrap.esm.min.js"
# Local modules
pin "range_defaults", preload: true
# Blacklight JavaScript (from gem - available via asset pipeline)
pin "blacklight", to: "blacklight/blacklight.js", preload: true
# Blacklight Range Limit dependencies
pin "chart.js", to: "https://ga.jspm.io/npm:chart.js@4.2.0/dist/chart.js"
pin "@kurkle/color", to: "https://ga.jspm.io/npm:@kurkle/color@0.3.2/dist/color.esm.js"
pin "blacklight-range-limit", preload: true