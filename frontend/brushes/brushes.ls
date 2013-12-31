class Brush
	(radius, color, canvas) ->
	
		@type = "default"
		@isTool = false
		@radius = radius
		@color = color
		@canvas = canvas
		
	actionStart: (x, y) !->
		
		@canvas.context.moveTo x, y
		# Set the line's color from the brush's color
		@canvas.context.strokeStyle = @color
		
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

class WireframeBrush extends Brush
	(radius, color, canvas) ->
	
		super ...
		@type = "wireframe"

	actionStart: (x, y) !->
		
		@canvas.context.moveTo x, y
		# Set the line's color from the brush's color
		@canvas.context.strokeStyle = @color
		
		# Start a new path, because we're on a new action
		@canvas.context.beginPath!
		
		# Set the line width from the brush's current radius
		@canvas.context.line-width = @canvas.action.radius
	
	actionEnd: !->
		
		@canvas.context.closePath!
	
	actionMove: (x, y) !->
	
		@canvas.context.line-to x, y
		numpoints = @canvas.action.coord_data.length
		if numpoints >= 4
			@canvas.context.lineTo @canvas.action.coord_data[numpoints-4][0], @canvas.action.coord_data[numpoints-4][1]
		@canvas.context.stroke!
		

	doAction: (data) !->
		
		@actionStart data[0][0], data[0][1]
		for i from 1 til data.length by 1
			@canvas.context.lineTo data[i][0], data[i][1]
			nearpoint = data[i-5]
			if nearpoint
				@canvas.context.moveTo nearpoint[0], nearpoint[1]
				@canvas.context.lineTo data[i][0], data[i][1]
		@canvas.context.stroke!
		@actionEnd!

class ColorSamplerBrush extends Brush
	(radius, color, canvas) ->
	
		super ...
		@type = "sampler"
		
	actionStart: (x, y) !->
	
		p = (@canvas.context.getImageData x, y, 1, 1).data
		
		r = ("0" + (p[0].toString 16)).slice -2
		g = ("0" + (p[1].toString 16)).slice -2
		b = ("0" + (p[2].toString 16)).slice -2
		
		hex = "#" + r + g + b
		@canvas.doColorChange hex
	
	actionEnd: !->
		return
		
	actionMove: (x, y) !->
		@actionStart x, y
		
	doAction: (data) !->
		return


getBrush = (brushtype, radius, color, canvas) ->
	| brushtype == 'default' => new Brush radius, color, canvas
	| brushtype == 'wireframe' => new WireframeBrush radius, color, canvas
	| brushtype == 'sampler' => new ColorSamplerBrush radius, color, canvas


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
