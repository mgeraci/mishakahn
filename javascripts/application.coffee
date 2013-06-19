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
  $("body").on "click", "#home ul a", (e)->
    e.preventDefault()

    $("#home .return-home").show() # block action on the home page

    # determing the center coords of #home
    home_center_x = ($("#stage").width() - $("#home").outerWidth()) / 2 * -1
    home_center_y = ($("#stage").height() - $("#home").outerHeight()) / 2 * -1
    home_center_x = "#{home_center_x / 2}px"
    home_center_y = "#{home_center_y / 2}px"

    # should be top: -2780px, left: -2390px
    console.log home_center_y
    console.log home_center_x
    #.transformOrigin(home_center_x, home_center_y)

    $("#stage").addClass "zoomed-out"

backHome = ->
  $("body").on "click", ".return-home", (e)->
    $("#home .return-home").hide()
    $("#stage").removeClass "zoomed-out"

jQuery.fn.transformOrigin = (x, y) ->
  $(this).css
    "-webkit-transform-origin": "#{x} #{y}"
    "-moz-transform-origin": "#{x} #{y}"
    "-ms-transform-origin": "#{x} #{y}"
    "-o-transform-origin": "#{x} #{y}"
    "transform-origin": "#{x} #{y}"
