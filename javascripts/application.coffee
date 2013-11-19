$ ->
	copyHomeMenu()
	setSizeAndResize()
	clickNavigation.initialize()
	#pan.initialize()
	info.initialize()


# Setup
################################################################################

# copy the home menu from #home to the position: fixed; one. TODO this should
# get output from the eventual backend
copyHomeMenu = ->
	return if $("#fixed-menu ul").length
	menu = $("#home ul").clone()
	$("#fixed-menu h1").after menu

setSizeAndResize = ->
	resizeFunction()

	debouncedResizeFunction = _.debounce resizeFunction, 100

	$(window).resize ->
		resizeFunction()

resizeFunction = ->
	width = $(window).width()
	height = $(window).height()

	sizeHome(width, height)
	setTransformOrigin(width, height)
	clickNavigation.getHomeCenterCoords()

sizeHome = (width, height)->
	$("#home").outerWidth width
	$("#home").outerHeight height

setTransformOrigin = (width, height)->
	$("#zoom-wrapper").transformOrigin "#{width / 2}px #{height / 2}px"


# Click-based navigation
################################################################################

clickNavigation = {
	transitionTime: 1200 # a sensible default
	homeX: 0
	homeY: 0

	initialize: ->
		@getTransitionTime()
		@getHomeCenterCoords()

		$("body").on "click", "ul.work-links a", (e)=>
			@goToPiece(e)

		$("body").on "click", ".return-home", (e)=>
			@returnHome()

	getTransitionTime: ->
		# get the transition time from the css
		transitionTime = $("#transition-time").css("transition").split(" ")[1]

		@transitionTime = if transitionTime.match(/ms$/)
			parseInt(trantisionTime.replace(/ms$/, ""), 10)
		else
			parseFloat(transitionTime.replace(/s$/, ""), 10) * 1000

	getHomeCenterCoords: ->
		position = $("#home").position()
		@homeX = position.left + $(window).width() / 2
		@homeY = position.top + $(window).height() / 2

	goToPiece: (e)->
		e.preventDefault()

		target = $("##{$(e.target).data "target"}")
		@moveToElement target

		# block action on the home page
		$("#home .return-home").show()

	returnHome: ->
		$("#home .return-home").hide()
		@moveToElement $("#home")

	# set the transform origin, zoom out, pan, and zoom in
	moveToElement: (el)->
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
			fieldX = centerOfElementX - @homeX
			fieldY = centerOfElementY - @homeY

		translateString = "translate(#{fieldX * -1}px, #{fieldY * -1}px)"

		$("#zoom-wrapper").addClass("zoomed-out")
		$("#stage").addClass("animating").transform "#{translateString}"

		setTimeout(=>
			$("#zoom-wrapper").removeClass("zoomed-out")
		, @transitionTime / 2)

		setTimeout(=>
			$("#stage").removeClass("animating")
		, @transitionTime)

		returnLink = $("#fixed-menu")
		if isHome
			returnLink.animate {opacity: 0}, @transitionTime / 2, ->
				returnLink.hide()
		else
			setTimeout(->
				returnLink.show().css {opacity: 0}
				returnLink.animate {opacity: 1}, @transitionTime / 2
			, @transitionTime)
}


# Pan-based navigation
################################################################################

pan = {
	# variables
	prevX: false
	prevY: false
	startCoords: {}
	endCoords: {}
	movementDuration: 0
	movementDurationTimeout: null

	# on mousedown, store click coords
	mouseDown: (e)->
	  return if $("#stage").hasClass("animating") ||
	    $(e.target).closest("#home").length ||
	    $(e.target).closest("a").length ||
	    $(e.target).closest("img").length ||
	    $(e.target).closest("#fixed-menu").length

	  $("#stage").stop(true).addClass "panning"

	  # reset drag coordinates
	  @prevX = false
	  @prevY = false

	  # set click coordinates
	  @startCoords.x = e.pageX
	  @startCoords.y = e.pageY

	  # start click timer
	  @movementDuration = 0
	  @setTimer()

	# on mouseup, animate momentum
	mouseUp: (e)->
	  return if $(e.target).closest("#home").length || $("#stage").hasClass "animating"
	  return unless $("#stage").hasClass "panning"
	  $("#stage").removeClass "panning"

	  # animate momentum on release
	  clearTimeout @movementDurationTimeout

	  @endCoords.x = e.pageX
	  @endCoords.y = e.pageY

	  xTravel = @endCoords.x - @startCoords.x
	  yTravel = (@endCoords.y - @startCoords.y) * -1 # invert y to convert from screen position to math

	  slope = if xTravel == 0 then 100 else yTravel / xTravel # arbitrary large number instead of ∞

	  distanceTraveled = Math.sqrt(xTravel * xTravel + yTravel * yTravel)
	  speed = ((distanceTraveled / @movementDuration) * 1000) || 0 # in pixels per second

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
	  maxxedCoords = @panMax(newX, newY)

	  if speed > 700
	    $("#stage").addClass("momentum").animate({
	      top: maxxedCoords[1]
	      left: maxxedCoords[0]
	    }, 1000, "easeOutQuint", ->
	      $("#stage").removeClass("momentum")
	    )

	# on mousemove, pan the canvas
	mouseMove: ->
		return unless $("#stage").hasClass "panning"
		currentPos = $("#stage").position()

		if @prevX? && @prevY? && @prevX != false && @prevY != false
			deltaX = e.pageX - @prevX
			deltaY = e.pageY - @prevY
			newX = currentPos.left + deltaX
			newY = currentPos.top + deltaY
			maxxedCoords = @panMax(newX, newY)

			$("#stage").css
				top: maxxedCoords[1]
				left: maxxedCoords[0]

		@prevX = e.pageX
		@prevY = e.pageY

	# set a trimeout to keep track of how long the user is panning
	setTimer: ->
		@movementDurationTimeout = setTimeout(@counter, 1)

	# recurse to count the duration of movement
	counter: ->
		@movementDuration++
		@setTimer()

	# do not allow a coord to go too far outside of the stage
	panMax: (newX, newY)->
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

	initialize: ->
		$("body").on "mousedown", (e)=>
			@mouseDown()

		$("body").on "mouseup", (e)=>
			@mouseUp()

		$("body").on "mousemove", (e)=>
			@mouseMove()
}


# hover on a piece to show info in a hovercard
info = {
	initialize: ->
		$("body").on "mouseenter", ".test", (e)=>
			@showHovercard(e.currentTarget)

		$("body").on "mouseleave", ".test", (e)=>
			@hideHovercard()

	showHovercard: (el)->
		params =
			title: $(el).data "title"
			year: $(el).data "year"
			text: $(el).data "text"

		$("#info").hide().empty().append @template(params)
		$("#info").stop(true, true).fadeIn()

	hideHovercard: ->
		$("#info").stop(true, true).fadeOut()

	template: (params)->
		"""
			<h1>#{params.title}</h1>
			<h2>#{params.year}</h2>
			<div class="text">#{params.text}</div>
		"""
}
