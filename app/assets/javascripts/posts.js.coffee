# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# app/assets/javascripts/posts.js.coffee

$(document).ready ->
  $("#posts-container .posts").infinitescroll
    navSelector: "nav.pagination"
    nextSelector: "nav.pagination a[rel=next]"
    itemSelector: "#posts-container div.post"
