duration = 2000 # how long each home => piece transition takes
prevX = false
prevY = false
startCoords = {}
endCoords = {}
movementDuration = 0
movementDurationTimeout = null

$ ->
  sizeHome()
  initializePosition()
  homeLinks()
  returnHome()
  pan()
  info()

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
    $("#stage").addClass "panning" unless $(e.target).closest("a").length

    # reset drag coordinates
    prevX = false
    prevY = false

    # set click coordinates
    startCoords.x = e.pageX
    startCoords.y = e.pageY

    # start click timer
    movementDuration = 0
    _setTimer()

  $("body").on "mouseup", (e)->
    return if $(e.target).closest("#home").length || $("#stage").hasClass "animating"
    return unless $("#stage").hasClass "panning"
    $("#stage").removeClass "panning"

    clearTimeout movementDurationTimeout

    # animate some momentum on release
    endCoords.x = e.pageX
    endCoords.y = e.pageY

    xTravel = endCoords.x - startCoords.x
    yTravel = (endCoords.y - startCoords.y) * -1 # invert y to convert from screen position to math

    slope = if xTravel == 0 then 100 else yTravel / xTravel # arbitrary large number instead of ∞

    distanceTraveled = Math.sqrt(xTravel * xTravel + yTravel * yTravel)
    speed = ((distanceTraveled / movementDuration) * 1000) || 0 # in pixels per second

    # range of speed is roughly 0-20000. convert to a reasonable range
    maxSpeed = 20000
    maxDistance = 800
    distance = (speed * maxDistance) / maxSpeed

    deltaX = distance / (Math.sqrt(slope * slope + 1))
    deltaX = deltaX * -1 if xTravel < 0

    deltaY = slope * deltaX

    newX = endCoords.x + deltaX
    newY = endCoords.y - deltaY # invert newY to convert from math to screen position

    if speed > 1000
      console.log 'animating'
      $("#stage").addClass("momentum").animate({
        top: "+=#{deltaY * -1}"
        left: "+=#{deltaX}"
      }, 1000, "easeOutQuint", ->
        console.log 'done'
        $("#stage").removeClass("momentum")
      )

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

_setTimer = ->
  movementDurationTimeout = setTimeout(_counter, 1)

_counter = ->
  movementDuration++
  _setTimer()


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
