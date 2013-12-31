class Brush
	(radius, color, canvas) ->
	
		@type = "default"
		@radius = radius
		@color = color
		@context = context
		
	actionStart: (x, y) ->
		
		canvas.context.moveTo x, y
		canvas.context.strokeStyle = color
		canvas.context.line-width = radius
		canvas.context.beginPath!
	
	actionEnd: ->
		
		canvas.context.endPath!
	
	actionMove: (x, y) ->
		
		canvas.context.line-to x, y
		canvas.context.stroke!

class ColorSamplerBrush extends Brush
	actionStart: (x, y) ->
	
		p = (context.getImageData x, y, 1, 1).data
		hex = "#" + (("000000" + (((p[0] << 16) | (p[1] << 8) | p[2]).toString 16)).slice -6)
		color = hex
		canvas.doColorChange color
	
	actionEnd: ->
		#lel I dunno, just something ought to be here
		color = color
		
	actionMove: (x, y) ->
		actionStart x y


"""wireframe-brush = (context, event, points) ->

	points.push [x:event.clientX, y: event.clientY]
	context.begin-path!

	context.move-to points[0].x, points[0].y

	for x in points
		context.line-to points[x].x, points[x].y
		nearpoint = [x-5]
		if nearpoint
			context.move-to nearpoint.x nearpoint.y
			context.line-to points[x].x, points[x].y
	context.stroke!

	points"""
