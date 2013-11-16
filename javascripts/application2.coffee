$ ->
	events()

events = ->
	$(".grid").click ->
		$(".active").removeClass "active"
		$(@).addClass "active"
		centerOnItem(@)

centerOnItem = (el)->
	item = $(el)
	position = item.position()
	width = item.width()
	height = item.height()

	centerX = Math.round(position.left + width / 2)
	centerY = Math.round(position.top + height / 2)

	fieldX = centerX - $("#wrapper").width() / 2
	fieldY = centerY - $("#wrapper").height() / 2

	#$("#field").css
		#top: centerY * -1
		#left: centerX * -1

	$("#field").transform "translate(#{fieldX * -1}px, #{fieldY * -1}px)"
