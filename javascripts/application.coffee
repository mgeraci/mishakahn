duration = 1000
scale = 1 # scale of the image
xLast = 0 # last x location on the screen
yLast = 0 # last y location on the screen
xImage = 0 # last x location on the image
yImage = 0 # last y location on the image

$ ->
  # TODO add window resize, debounced
  sizeHome()
  #initializePosition()
  homeLinks()
  backHome()

  #$("body").click ->
    #doctypeZoom 2

sizeHome = ->
  $("#home").outerWidth $(window).width()
  $("#home").outerHeight $(window).height()

initializePosition = ->
  _centerStageOn $("#home")

homeLinks = ->
  $("body").on "click", "#home ul a", (e)->
    e.preventDefault()

    target = $(e.target).data "target"

    $("#home .return-home").show() # block action on the home page
    #$("#stage").addClass "zoomed-out"
    _centerStageOn $("##{target}")
    _positionStageOn $("##{target}")
    #setTimeout(->
      #$("#stage").removeClass "zoomed-out"
    #, duration)

backHome = ->
  $("body").on "click", ".return-home", (e)->
    $("#home .return-home").hide()
    $("#stage").removeClass "zoomed-out"

##################################################

_centerStageOn = (el)->
  elCoords = $(el).centerCoords(true)
  console.log elCoords

  #str = "#{x}px #{y}px"
  #str = "#{x}% #{y}%"

  $("#stage").transformOrigin "#{elCoords.left} #{elCoords.top}"

_positionStageOn = (el)->
  pos = $(el).position()
  top = pos.top * -1 + ($(window).height() - el.outerHeight()) / 2
  left = pos.left * -1 + ($(window).width() - el.outerWidth()) / 2

  $("#stage").transform "scale(1) translate(#{left}px, #{top}px)"

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

############################################


# adapted from http://doctype.com/javascript-image-zoom-css3-transforms-calculate-origin-example
window.doctypeZoom = (delta)->
  # find current location on screen
  #xScreen = e.pageX - $(this).offset().left
  #yScreen = e.pageY - $(this).offset().top
  xScreen = $("#home").position().left + $("#home").outerWidth() / 2 - $("#stage").offset().left * 2
  yScreen = $("#home").position().top + $("#home").outerHeight() / 2 - $("#stage").offset().top * 2
  #xScreen = 0
  #yScreen = 0
  console.log "screen:", xScreen, yScreen

  # find current location on the image at the current scale
  xImage = xImage + ((xScreen - xLast) / scale)
  yImage = yImage + ((yScreen - yLast) / scale)
  console.log "image:", xImage, yImage

  # determine the new scale
  if delta > 0
    scale *= 2
  else
    scale /= 2

  min = 0.15
  max = 4
  scale = if scale < min then min else (if scale > max then max else scale)

  # determine the location on the screen at the new scale
  xNew = (xScreen - xImage) / scale
  yNew = (yScreen - yImage) / scale

  # save the current screen location
  xLast = xScreen
  yLast = yScreen

  console.log "new:", xNew, yNew, scale

  $("#stage").transform "scale(#{scale}) translate(#{xNew}px, #{yNew}px)"
  $("#stage").dtTransformOrigin "#{xImage}px #{yImage}px"

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
