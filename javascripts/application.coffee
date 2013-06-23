duration = 2000

$ ->
  sizeHome()
  initializePosition()
  homeLinks()
  returnHome()

# TODO add window resize, debounced
sizeHome = ->
  $("#home").outerWidth $(window).width()
  $("#home").outerHeight $(window).height()

initializePosition = ->
  _setStageOriginTo $("#home")

homeLinks = ->
  $("body").on "click", "#home ul a", (e)->
    e.preventDefault()

    target = $("##{$(e.target).data "target"}")
    _moveToElement target

    $("#home .return-home").show() # block action on the home page

returnHome = ->
  $("body").on "click", ".return-home", (e)->
    console.log 'hoooome'
    $("#home .return-home").hide()
    _moveToElement $("#home")


##################################################
# position helpers

# set the transform origin, zoom out, pan, and zoom in
_moveToElement = (el)->
  _setStageOriginTo el
  $("#stage").addClass "zoomed-out"
  _positionStageOn el

  setTimeout(->
    $("#stage").removeClass "zoomed-out"
  , duration / 2)

  if el.attr("id") == "home"
    $("#fixed-return-home").fadeOut duration
  else
    setTimeout(->
      $("#fixed-return-home").fadeIn duration
    , duration + 500)

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
