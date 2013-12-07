$ ->
	copyHomeMenu()
	setSizeAndResize()
	hovercards.initialize()

	if $("html").hasClass("csstransforms") && $("html").hasClass("csstransitions")
		clickNavigation.initialize()
		pan.initialize()
	else
		noCSS3Navigation.initialize()


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

# on resize, set the size of #home to the window's size, and set the transform-
# origin of the zoom wrapper to the center of the viewport
resizeFunction = ->
	width = $(window).width()
	height = $(window).height()

	$("#home").outerWidth width
	$("#home").outerHeight height

	$("#zoom-wrapper").transformOrigin "#{width / 2}px #{height / 2}px"

	clickNavigation.getHomeCenterCoords()
	pan.calculateMaxes()


# Click-based navigation
################################################################################

clickNavigation = {
	transitionTime: 1200 # a sensible default
	homeX: 0
	homeY: 0

	initialize: ->
		@getHomeCenterCoords()

		$("body").on "click", "ul.work-links a", (e)=>
			@goToPiece(e)

		$("body").on "click", ".return-home", (e)=>
			@returnHome()

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
		goingHome = element.attr("id") == "home"

		# center of the element
		centerOfElementX = Math.round(position.left + width / 2)
		centerOfElementY = Math.round(position.top + height / 2)

		# how far to move the field
		if goingHome
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

		menu = $("#fixed-menu")
		if goingHome
			menu.removeClass("show")

		setTimeout(=>
			$("#stage").removeClass("animating")

			if !goingHome
				menu.addClass("show")
		, @transitionTime)
}


# Pan-based navigation
################################################################################

pan = {
	# calculate pan and delta
	prevX: false
	prevY: false
	startCoords: {}
	endCoords: {}

	# track the length of the pan motion
	movementDuration: 0
	movementDurationTimeout: null
	momentumTimeout: null

	# keep the user from panning out of the field.
	# variables set in calculateMaxes().
	padding: 20
	minX: 0
	maxX: 0
	minY: 0
	maxY: 0

	initialize: ->
		$("body").on "mousedown", (e)=>
			@mouseDown(e)

		$("body").on "mouseup", (e)=>
			@mouseUp(e)

		$("body").on "mousemove", (e)=>
			@mouseMove(e)

	# on mousedown, store click coords
	mouseDown: (e)->
		return if $("#stage").hasClass("animating") ||
			$(e.target).closest("#home").length ||
			$(e.target).closest("a").length ||
			$(e.target).closest("img").length ||
			$(e.target).closest("#fixed-menu").length

		# kill momentum if it's happening
		if $("#stage").hasClass("momentum")
			clearTimeout(@momentumTimeout)

			currentPos = @getTranslation($("#stage"))
			$("#stage").removeClass("momentum")
				.transform "translate(#{currentPos[0]}px, #{currentPos[1]}px"

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

		# range of speed is roughly 0-20k. convert to a reasonable range
		maxSpeed = 20000
		maxDistance = 800
		distance = (speed * maxDistance) / maxSpeed

		deltaX = distance / (Math.sqrt(slope * slope + 1))
		deltaX = deltaX * -1 if xTravel < 0
		deltaY = slope * deltaX

		currentPos = @getTranslation($("#stage"))
		newX = currentPos[0] + deltaX
		newY = currentPos[1] - deltaY
		maxxedCoords = @panMax(newX, newY)

		if speed > 2200
			$("#stage").addClass("momentum")
				.transform "translate(#{maxxedCoords[0]}px, #{maxxedCoords[1]}px"

			@momentumTimeout = setTimeout(->
				$("#stage").removeClass("momentum")
			, 1000)

	# on mousemove, pan the canvas. track the mouse's position across the
	# viewport to get the x and y deltas, then apply that to the current
	# css translation
	mouseMove: (e)->
		return unless $("#stage").hasClass "panning"
		currentPos = @getTranslation($("#stage"))

		if @prevX? && @prevY? && @prevX != false && @prevY != false
			deltaX = e.pageX - @prevX
			deltaY = e.pageY - @prevY
			newX = currentPos[0] + deltaX
			newY = currentPos[1] + deltaY
			maxxedCoords = @panMax(newX, newY)

			$("#stage").transform "translate(#{maxxedCoords[0]}px, #{maxxedCoords[1]}px"

		@prevX = e.pageX
		@prevY = e.pageY

	# set a trimeout to keep track of how long the user is panning
	setTimer: ->
		@movementDurationTimeout = setTimeout(@counter.bind(@), 1)

	# recurse to count the duration of movement
	counter: ->
		@movementDuration++
		@setTimer()

	# get [x, y] coordinates from a css3 translation
	getTranslation: (el)->
		matrix = el.css("-webkit-transform") ||
			el.css("-moz-transform")           ||
			el.css("-ms-transform")            ||
			el.css("-o-transform")             ||
			el.css("transform")

		if matrix != 'none'
			matrix = matrix.replace(/.+\(/, "").replace(/\)(.+)?/, "").split(",")

			return [parseFloat(matrix[4], 10), parseFloat(matrix[5], 10)]
		else
			return false

	calculateMaxes: ->
		homePosition = $("#home").position()
		homeWidth = $("#home").width()
		homeHeight = $("#home").height()
		stageWidth = $("#stage").width()
		stageHeight = $("#stage").height()

		@maxX = homePosition.left + @padding
		@maxY = homePosition.top + @padding

		@minX = (stageWidth - homePosition.left - homeWidth - @padding) * -1
		@minY = (stageHeight - homePosition.top - homeHeight - @padding) * -1

	# do not allow a coord to go too far outside of the stage
	panMax: (x, y)->
		x = @minX if x < @minX
		y = @minY if y < @minY
		x = @maxX if x > @maxX
		y = @maxY if y > @maxY

		[x, y]
}


# Navigation for browsers without css3 transition support
################################################################################

noCSS3Navigation = {
	initialize: ->
		$("body").on "click", "ul.work-links a", (e)=>
			@goToPiece(e)

		$("body").on "click", ".return-home", (e)=>
			@returnHome()

	goToPiece: (e)->
		e.preventDefault()

		target = $("##{$(e.target).data "target"}")
		@moveToElement target

		# block action on the home page
		$("#home .return-home").show()

	returnHome: ->
		$("#home .return-home").hide()
		@moveToElement $("#home")

	moveToElement: (target)->
		goingHome = target.attr("id") == "home"
		targetPosition = target.position()
		targetWidth = target.outerWidth()
		targetHeight = target.outerHeight()
		viewportWidth = $(window).width()
		viewportHeight = $(window).height()

		stageTop = targetPosition.top * -1 + (viewportHeight - targetHeight) / 2
		stageLeft = targetPosition.left * -1 + (viewportWidth - targetWidth) / 2

		$("#stage").css
			top: stageTop
			left: stageLeft

		menu = $("#fixed-menu")
		if goingHome
			menu.removeClass("show")
		else
			menu.addClass("show")
}


# hover on a piece to show info in a hovercard
################################################################################
#
hovercards = {
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

		$("#info").empty().append @template(params)
		$("#info").addClass("show")

	hideHovercard: ->
		$("#info").removeClass("show")

	template: (params)->
		"""
			<h1>#{params.title}</h1>
			<h2>#{params.year}</h2>
			<div class="text">#{params.text}</div>
		"""
}
