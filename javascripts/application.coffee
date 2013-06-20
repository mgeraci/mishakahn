duration = 1000

$ ->
  # TODO add window resize, debounced
  sizeHome()
  homeLinks()
  backHome()

sizeHome = ->
  $("#home").outerWidth $(window).width()
  $("#home").outerHeight $(window).height()

homeLinks = ->
  homeCoords = $("#home").centerCoords()
  $("#stage").transformOrigin(homeCoords.left, homeCoords.top)

  $("body").on "click", "#home ul a", (e)->
    e.preventDefault()

    $("#home .return-home").show() # block action on the home page

    homeCoords = $("#home").centerCoords()

    $("#stage")
      .addClass "zoomed-out"

backHome = ->
  $("body").on "click", ".return-home", (e)->
    $("#home .return-home").hide()
    $("#stage").removeClass "zoomed-out"

jQuery.fn.transformOrigin = (x, y) ->
  str = "#{x}px #{y}px"
  str = "#{x}% #{y}%"

  $(this).css
    "-webkit-transform-origin": "#{str}"
    "-moz-transform-origin": "#{str}"
    "-ms-transform-origin": "#{str}"
    "-o-transform-origin": "#{str}"
    "transform-origin": "#{str}"

jQuery.fn.centerCoords = ->
  pos = $(this).position()

  top = $(this).outerHeight() / 2 + pos.top
  left = $(this).outerWidth() / 2 + pos.left

  top = (top * 100) / $("#stage").height()
  left = (left * 100) / $("#stage").width()

  {
    top: top
    left: left
  }
