cclass Brush
	(radius, color, canvas) ->
	
		@type = "default"
		@isTool = false
		@radius = radius
		@color = color
		@canvas = canvas
		
	actionStart: (x, y) !->
		
		@canvas.context.moveTo x, y
		# Set the line's color from the brush's color
		@canvas.context.strokeStyle = @canvas.action.fillColor
		
		# Start a new path, because we're on a new action
		@canvas.context.beginPath!
		
		# Set the line width from the brush's current radius
		@canvas.context.line-width = @canvas.action.radius

		# get rid of those nasty turns
		@canvas.context.line-join = @canvas.context.line-cap = 'round'
	
	actionEnd: !->
		
		@canvas.context.closePath!
	
	actionMove: (x, y) !->
		
		@canvas.context.line-to x, y
		@canvas.context.stroke!
		
	doAction: (data) !->
		
		@actionStart data[0][0], data[0][1]
		for p in data
			@canvas.context.line-to p[0], p[1]
		@canvas.context.stroke!
		@actionEnd!

class ColorSamplerBrush extends Brush
	(radius, color, canvas) ->
	
		@type = "sampler"
		@isTool = true
		@radius = radius
		@color = color
		@canvas = canvas
		
	actionStart: (x, y) !->
	
		p = (@canvas.context.getImageData x, y, 1, 1).data
		hex = "#" + (("000000" + (((p[0] << 16) .|. (p[1] << 8) .|. p[2]).toString 16)).slice -6)
		color = hex
		canvas.doColorChange color
	
	actionEnd: !->
		#lel I dunno, just something ought to be here
		color = color
		
	actionMove: (x, y) !->
		actionStart x y
		
	doAction: (data) !->
		#I really should see about just voiding these or something...
		data[0][0]


getBrush = (brushtype, radius, color, canvas) ->
	| brushtype == 'default' => new Brush radius, color, canvas
	| brushtype == 'sampler' => new Brush radius, color, canvas


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

"""
sketch-brush = (context, event, points) ->

	points.push [x:event.clientX, y: event.clientY]
	context.moveTo points[points.length - 2].x, points[points.length - 2].y
	context.lineTo points[points.length - 1].x, points[points.length - 1].y
	context.stroke!

	lastPoint = points[points.length-1]

	for i in points
		dx = points[i].x - lastPoint.x;
		dy = points[i].y - lastPoint.y;
		d = dx * dx + dy * dy;

		if d < 1000
			context.beginPath()
			context.strokeStyle = 'rgba(0,0,0,0.3)'
			context.moveTo(lastPoint.x + (dx * 0.2), lastPoint.y + (dy * 0.2))
			context.ctx.lineTo(points[i].x - (dx * 0.2), points[i].y - (dy * 0.2))
			context.stroke!

"""