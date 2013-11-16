$ ->
	events()
	setTransformOrigin() # run this on resize

events = ->
	$(".grid").click ->
		$(".active").removeClass "active"
		$(@).addClass "active"
		centerOnItem(@)

setTransformOrigin = ->
	$("#zoom-wrapper").transformOrigin "#{$("#wrapper").width() / 2}px #{$("#wrapper").height() / 2}px"

centerOnItem = (el)->
	item = $(el)
	position = item.position()
	width = item.width()
	height = item.height()

	# center of the element
	centerX = Math.round(position.left + width / 2)
	centerY = Math.round(position.top + height / 2)

	# offset for the field
	fieldX = centerX - $("#wrapper").width() / 2
	fieldY = centerY - $("#wrapper").height() / 2

	# get the transition time from the css
	transitionTime = $("#field").css("transition").split(" ")[1]
	transitionTime = if transitionTime.match(/ms$/)
		parseInt(trantisionTime.replace(/ms$/, ""), 10)
	else
		parseFloat(transitionTime.replace(/s$/, ""), 10) * 1000

	translateString = "translate(#{fieldX * -1}px, #{fieldY * -1}px)"

	$("#zoom-wrapper").addClass("zoomed-out")
	$("#field").transform "#{translateString}"

	setTimeout(=>
		console.log "done!"
		$("#zoom-wrapper").removeClass("zoomed-out")
	, transitionTime / 2)
