// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import * as bootstrap from "bootstrap"
window.bootstrap = bootstrap
import githubAutoCompleteElement from "@github/auto-complete-element"
import Blacklight from "blacklight"
import BlacklightRangeLimit from "blacklight-range-limit"
import "range_defaults"


window.Blacklight = Blacklight;

// Initialize Blacklight Range Limit
BlacklightRangeLimit.init({ onLoadHandler: Blacklight.onLoad });

// Blacklight ships behaviors that must be (re)bound after Turbo navigations.
document.addEventListener("turbo:load", () => {
  if (window.Blacklight?.onLoad) window.Blacklight.onLoad();
});


// document.addEventListener('DOMContentLoaded', function() {
//     console.log('This JavaScript runs on all pages.');
//     // Add your global JavaScript here
//   });

