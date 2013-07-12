duration = 2000
prevX = false
prevY = false
mousePos = false
momentumX = 0
momentumY = 0
slope = 0
speed = 0

$ ->
  sizeHome()
  initializePosition()
  homeLinks()
  returnHome()
  pan()
  info()
  movementStats()

sizeHome = ->
  _sizeHome()

  $(window).resize ->
    _sizeHome()

_sizeHome = ->
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
    $("#home .return-home").hide()
    _moveToElement $("#home")

# track mouseclick state, if pressed, check mouse position
# and reposition the stage accordingly
pan = ->
  $("body").on "mousedown", (e)->
    return if $(e.target).closest("#home").length || $("#stage").hasClass "animating"
    $("#stage").addClass "panning"

    # reset drag coordinates
    prevX = false
    prevY = false

  $("body").on "mouseup", (e)->
    return if $(e.target).closest("#home").length || $("#stage").hasClass "animating"
    $("#stage").removeClass "panning"

  $("body").on "mousemove", (e)->
    return unless $("#stage").hasClass "panning"
    currentPos = $("#stage").position()

    if prevX? && prevY? && prevX != false && prevY != false
      deltaX = e.pageX - prevX
      deltaY = e.pageY - prevY
      newX = currentPos.left + deltaX
      newY = currentPos.top + deltaY

      # a little padding to show around the edges of the stage
      padding = 20
      maxX = ($("#stage").width() - $(window).width()) * -1 - padding
      maxY = ($("#stage").height() - $(window).height()) * -1 - padding

      # keep from panning out of the boundaries
      newX = padding if newX > padding # left
      newY = padding if newY > padding # top
      newX = maxX if newX < maxX # right
      newY = maxY if newY < maxY # bottom

      $("#stage").css
        top: newY
        left: newX

    prevX = e.pageX
    prevY = e.pageY

# hover on a piece to show info in a hovercard
info = ->
  $("body").on "mouseenter", ".test", (e)->
    title = $(@).data "title"
    year = $(@).data "year"
    text = $(@).data "text"

    $("#info").hide().empty().append """
      <h1>#{title}</h1>
      <h2>#{year}</h2>
      <div class="text">#{text}</div>
    """

    $("#info").stop(true, true).fadeIn()

  $("body").on "mouseleave", ".test", (e)->
    $("#info").stop(true, true).fadeOut()

movementDur = 500
movementStats = ->
  $("body").on "mousemove", (e)->
    mousePos = e

  _movementTimeout()

_movementTimeout = ->
  setTimeout(->
    xTravel = mousePos.pageX - momentumX
    yTravel = mousePos.pageY - momentumY
    xTravel = 0.0000000001 if xTravel == 0
    yTravel = 0.0000000001 if yTravel == 0

    slope = yTravel / xTravel
    distance = Math.sqrt(Math.abs(xTravel + yTravel))
    speed = distance / movementDur # as pixels per duration, which will change if we change duration

    momentumX = mousePos.pageX
    momentumY = mousePos.pageY

    _movementTimeout()
  , movementDur)


##################################################
# position helpers

# set the transform origin, zoom out, pan, and zoom in
_moveToElement = (el)->
  _setStageOriginTo el
  $("#stage").addClass "zoomed-out animating"
  _positionStageOn el

  setTimeout(->
    $("#stage").removeClass "zoomed-out"
  , duration / 2)

  setTimeout(->
    $("#stage").removeClass "animating"
  , duration * 2)

  returnLink = $("#fixed-return-home")
  if el.attr("id") == "home"
    returnLink.animate {opacity: 0}, duration / 2, ->
      returnLink.hide()
  else
    setTimeout(->
      returnLink.show().css {opacity: 0}
      $("#fixed-return-home").animate {opacity: 1}, duration / 2
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
