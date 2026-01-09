// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import bootstrap from "bootstrap"
import githubAutoCompleteElement from "@github/auto-complete-element"
import Blacklight from "blacklight"
import BlacklightRangeLimit from "blacklight-range-limit"
import "./range_defaults"  


window.Blacklight = Blacklight;

// Initialize Blacklight Range Limit
BlacklightRangeLimit.init({ onLoadHandler: Blacklight.onLoad });


// document.addEventListener('DOMContentLoaded', function() {
//     console.log('This JavaScript runs on all pages.');
//     // Add your global JavaScript here
//   });

