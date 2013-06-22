duration = 2000
scale = 1 # scale of the image
xLast = 0 # last x location on the screen
yLast = 0 # last y location on the screen
xImage = 0 # last x location on the image
yImage = 0 # last y location on the image

$ ->
  # TODO add window resize, debounced
  sizeHome()
  initializePosition()
  homeLinks()
  returnHome()

sizeHome = ->
  $("#home").outerWidth $(window).width()
  $("#home").outerHeight $(window).height()

initializePosition = ->
  _setStageOriginTo $("#home")

homeLinks = ->
  $("body").on "click", "#home ul a", (e)->
    e.preventDefault()

    target = $(e.target).data "target"

    $("#home .return-home").show() # block action on the home page

    _setStageOriginTo $("##{target}")
    $("#stage").addClass "zoomed-out"
    _positionStageOn $("##{target}")
    setTimeout(->
      $("#stage").removeClass "zoomed-out"
    , duration / 2)

    $("#fixed-return-to-home").fadeIn duration

returnHome = ->
  $("body").on "click", ".return-home", (e)->
    $("#home .return-home").hide()
    $("#stage").removeClass "zoomed-out"

##################################################

_setStageOriginTo = (el)->
  elCoords = $(el).centerCoords()
  $("#stage").transformOrigin "#{elCoords.left} #{elCoords.top}"

_positionStageOn = (el)->
  pos = $(el).position()
  top = pos.top * -1 + ($(window).height() - el.outerHeight()) / 2
  left = pos.left * -1 + ($(window).width() - el.outerWidth()) / 2

  #$("#stage").transform "scale(1) translate(#{left}px, #{top}px)"
  $("#stage").css
    top: top
    left: left

# return the center coordinates of an element.
# defaults to px, optional %
jQuery.fn.centerCoords = (percent = false)->
  pos = $(this).position()

  top = $(this).outerHeight() / 2 + pos.top
  left = $(this).outerWidth() / 2 + pos.left
  suffix = "px"

  if percent
    top = (top * 100) / $("#stage").height()
    left = (left * 100) / $("#stage").width()
    suffix = "%"

  {
    top: top + suffix
    left: left + suffix
  }

###########################################
# css3 helpers

jQuery.fn.transform = (args)->
  $(this).css
    "-webkit-transform": args
    "-moz-transform": args
    "transform": args

jQuery.fn.transformOrigin = (args)->
  $(this).css
    "-webkit-transform-origin": args
    "-moz-transform-origin": args
    "-ms-transform-origin": args
    "-o-transform-origin": args
    "transform-origin": args
