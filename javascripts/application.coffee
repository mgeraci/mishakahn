transitionTime = 0
homeX = 0
homeY = 0
prevX = false
prevY = false
startCoords = {}
endCoords = {}
movementDuration = 0
movementDurationTimeout = null

$ ->
	getTransitionTime()
	setTransformOrigin() # run this on resize
	getHomePosition()
	copyHomeMenu()
	sizeHome()
	workLinks()
	returnHome()
	pan()
	info()

# Setup
###############################################################################

# get the transition time from the css
getTransitionTime = ->
	transitionTime = $("#transition-time").css("transition").split(" ")[1]

	transitionTime = if transitionTime.match(/ms$/)
		parseInt(trantisionTime.replace(/ms$/, ""), 10)
	else
		parseFloat(transitionTime.replace(/s$/, ""), 10) * 1000

setTransformOrigin = ->
	x = $("#wrapper").width() / 2
	y = $("#wrapper").height() / 2
	$("#zoom-wrapper").transformOrigin "#{x}px #{y}px"

getHomePosition = ->
	position = $("#home").position()
	homeX = position.left + $(window).width() / 2
	homeY = position.top + $(window).height() / 2

copyHomeMenu = ->
	return if $("#fixed-menu ul").length
	menu = $("#home ul").clone()
	$("#fixed-menu h1").after menu

sizeHome = ->
	_sizeHome()

	$(window).resize ->
	  _sizeHome()

_sizeHome = ->
	$("#home").outerWidth $(window).width()
	$("#home").outerHeight $(window).height()

# Click-based navigation
###############################################################################

workLinks = ->
	$("body").on "click", "ul.work-links a", (e)->
	  e.preventDefault()

	  target = $("##{$(e.target).data "target"}")
	  _moveToElement target

	  $("#home .return-home").show() # block action on the home page

returnHome = ->
	$("body").on "click", ".return-home", (e)->
	  $("#home .return-home").hide()
	  _moveToElement $("#home")

# Pan-based navigation
###############################################################################

# track mouseclick state, if pressed, check mouse position
# and reposition the stage accordingly
pan = ->
	# on mousedown, store click coords
	$("body").on "mousedown", (e)->
	  return if $("#stage").hasClass("animating") ||
	    $(e.target).closest("#home").length ||
	    $(e.target).closest("a").length ||
	    $(e.target).closest("img").length ||
	    $(e.target).closest("#fixed-menu").length

	  $("#stage").stop(true).addClass "panning"

	  # reset drag coordinates
	  prevX = false
	  prevY = false

	  # set click coordinates
	  startCoords.x = e.pageX
	  startCoords.y = e.pageY

	  # start click timer
	  movementDuration = 0
	  _setTimer()

	# on mouseup, animate momentum
	$("body").on "mouseup", (e)->
	  return if $(e.target).closest("#home").length || $("#stage").hasClass "animating"
	  return unless $("#stage").hasClass "panning"
	  $("#stage").removeClass "panning"

	  # animate momentum on release
	  clearTimeout movementDurationTimeout

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

	  pos = $("#stage").position()
	  newX = pos.left + deltaX
	  newY = pos.top - deltaY
	  maxxedCoords = _panMax(newX, newY)

	  if speed > 700
	    $("#stage").addClass("momentum").animate({
	      top: maxxedCoords[1]
	      left: maxxedCoords[0]
	    }, 1000, "easeOutQuint", ->
	      $("#stage").removeClass("momentum")
	    )

	# on mousemove, pan the canvas
	$("body").on "mousemove", (e)->
	  return unless $("#stage").hasClass "panning"
	  currentPos = $("#stage").position()

	  if prevX? && prevY? && prevX != false && prevY != false
	    deltaX = e.pageX - prevX
	    deltaY = e.pageY - prevY
	    newX = currentPos.left + deltaX
	    newY = currentPos.top + deltaY
	    maxxedCoords = _panMax(newX, newY)

	    $("#stage").css
	      top: maxxedCoords[1]
	      left: maxxedCoords[0]

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
	element = $(el)
	position = element.position()
	width = element.width()
	height = element.height()
	isHome = element.attr("id") == "home"

	# center of the element
	centerOfElementX = Math.round(position.left + width / 2)
	centerOfElementY = Math.round(position.top + height / 2)

	# how far to move the field
	if isHome
		fieldX = 0
		fieldY = 0
	else
		fieldX = centerOfElementX - homeX
		fieldY = centerOfElementY - homeY

	translateString = "translate(#{fieldX * -1}px, #{fieldY * -1}px)"

	$("#zoom-wrapper").addClass("zoomed-out")
	$("#stage").addClass("animating").transform "#{translateString}"

	setTimeout(=>
		$("#zoom-wrapper").removeClass("zoomed-out")
	, transitionTime / 2)

	setTimeout(=>
		$("#stage").removeClass("animating")
	, transitionTime)

	returnLink = $("#fixed-menu")
	if isHome
	  returnLink.animate {opacity: 0}, transitionTime / 2, ->
	    returnLink.hide()
	else
	  setTimeout(->
	    returnLink.show().css {opacity: 0}
	    returnLink.animate {opacity: 1}, transitionTime / 2
	  , transitionTime)

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

# do not allow a coord to go too far outside of the stage
_panMax = (newX, newY)->
	# a little padding to show around the edges
	padding = 20
	maxX = ($("#stage").width() - $(window).width()) * -1 - padding
	maxY = ($("#stage").height() - $(window).height()) * -1 - padding

	# keep from panning out of the boundaries
	newX = padding if newX > padding # left
	newY = padding if newY > padding # top
	newX = maxX if newX < maxX # right
	newY = maxY if newY < maxY # bottom

	[newX, newY]


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
