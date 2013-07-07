duration = 2000
prevX = false
prevY = false

$ ->
  sizeHome()
  initializePosition()
  homeLinks()
  returnHome()
  pan()

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
    $("#home .return-home").hide()
    _moveToElement $("#home")
		
pan = ->
	$("body").on "mousedown", (e)->
		return if $(e.target).closest("#home").length || $("#stage").hasClass "zoomed-out"
		$("#stage").addClass "panning"
		prevX = false
		prevY = false
		
	$("body").on "mouseup", (e)->
		return if $(e.target).closest("#home").length || $("#stage").hasClass "zoomed-out"
		$("#stage").removeClass "panning"

	$("body").on "mousemove", (e)->
		return unless $("#stage").hasClass "panning"
		currentPos = $("#stage").position()

		if prevX? && prevY? && prevX != false && prevY != false
			deltaX = e.pageX - prevX
			deltaY = e.pageY - prevY
			newX = currentPos.left + deltaX
			newY = currentPos.top + deltaY

			# a little padding to show
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
