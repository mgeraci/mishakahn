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

	#$("#field").css
		#top: centerY * -1
		#left: centerX * -1

	$("#field").transform "translate(#{centerX * -1}px, #{centerY * -1}px)"
