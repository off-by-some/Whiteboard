rgb2hsl = (rgbcolor) !->
	r = rgbcolor[0] / 255.0
	g = rgbcolor[1] / 255.0
	b = rgbcolor[2] / 255.0
	
	var h, s, l
	
	min = Math.min r, g, b
	max = Math.max r, g, b
	delta_max = max - min
	l = (min + max) / 2.0
	if delta_max == 0
		h = s = 0
	else
		s = if (l < 0.5) then delta_max / (max + min) else delta_max / (2.0 - max - min)
		delta_r = (((max - r) / 6.0) + (delta_max / 2.0)) / delta_max
		delta_g = (((max - g) / 6.0) + (delta_max / 2.0)) / delta_max
		delta_b = (((max - b) / 6.0) + (delta_max / 2.0)) / delta_max
		console.log "r, g, b, max: " + r + "," + g + "," + b + "," + max
		if r == max
			h = delta_b - delta_g
		else if g == max
			h = (1.0 / 3.0) + delta_r - delta_b
		else if b == max
			h = (2.0 / 3.0) + delta_g - delta_r
		if h < 0.0 then h += 1.0
		if h > 1.0 then h -= 1.0
	return [h, s, l]

hsl2rgb = (hslcolor) !->
	var r, g, b
	
	h = hslcolor[0]
	s = hslcolor[1]
	l = hslcolor[2]
	
	if s == 0
		r = g = b = Math.round (l * 255.0)
	else
		temp0 = if (l < 0.5) then (l * (1.0 + s)) else ((l + s) - (s * l))
		temp1 = 2 * l - temp0
		huefunc = (v1, v2, vH) !->
			if vH < 0.0 then vH += 1.0
			if vH > 1.0 then vH -= 1.0
			if ((6.0 * vH) < 1.0) then return (v1 + (v2 - v1) * 6.0 * vH)
			if ((2.0 * vH) < 1.0) then return v2
			if ((3.0 * vH) < 2.0) then return (v1 + (v2 - v1) * ((2.0 / 3.0) - vH) * 6.0)
			return v1
		r = Math.round (255.0 * (huefunc temp0, temp1, h + (1.0 / 3.0)))
		g = Math.round (255.0 * (huefunc temp0, temp1, h))
		b = Math.round (255.0 * (huefunc temp0, temp1, h - (1.0 / 3.0)))
	return [r, g, b]

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
		@canvas.context.strokeStyle = "rgba(" + @color[0] + "," + @color[1] + "," + @color[2] + "," + @color[3] + ")"
		
		# Start a new path, because we're on a new action
		@canvas.context.beginPath!
		
		# Set the line width from the brush's current radius
		@canvas.context.line-width = @radius

		# get rid of those nasty turns
		@canvas.context.line-join = @canvas.context.line-cap = 'round'
	
	actionEnd: !->
		
		@canvas.context.closePath!
	
	actionMove: (x, y) !->
		
		@canvas.context.line-to x, y
		@canvas.context.stroke!
		@canvas.action.data.push [x, y]
	
	actionMoveData: (data) !->
		for p in data
			@canvas.context.line-to p[0], p[1]
		@canvas.context.stroke!
		
	doAction: (data) !->
		unless data.length == 0
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
		@canvas.context.strokeStyle = "rgba(" + @color[0] + "," + @color[1] + "," + @color[2] + "," + @color[3] + ")"
		
		# Start a new path, because we're on a new action
		@canvas.context.beginPath!
		
		# Set the line width from the brush's current radius
		@canvas.context.line-width = @radius
	
	actionEnd: !->
		
		@canvas.context.closePath!
	
	actionMove: (x, y) !->
	
		@canvas.context.line-to x, y
		numpoints = @canvas.action.data.length
		if numpoints >= 4
			@canvas.context.lineTo @canvas.action.data[numpoints-4][0], @canvas.action.data[numpoints-4][1]
		@canvas.context.stroke!
		@canvas.action.data.push [x, y]
	
	actionMoveData: (data) !->
		for i from 1 til data.length by 1
				@canvas.context.lineTo data[i][0], data[i][1]
				nearpoint = data[i-5]
				if nearpoint
					@canvas.context.moveTo nearpoint[0], nearpoint[1]
					@canvas.context.lineTo data[i][0], data[i][1]
		@canvas.context.stroke!

	doAction: (data) !->
		unless data.length == 0
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
		
		# getImageData gives alpha as an int from 0-255, we need a float from 0.0-1.0
		a = p[3] / 255.0
		
		# hex = "rgba(" + p[0] + "," +  p[1] + "," + p[2] + "," + a + ")"
		@canvas.doColorChange [p[0], p[1], p[2], a]
	
	actionEnd: !->
		return
		
	actionMove: (x, y) !->
		@actionStart x, y
	
	actionMoveData: (data) ->
		return
		
	doAction: (data) !->
		return

class Lenny extends Brush
	(radius, color, canvas) ->
		
		super ...
		@type = "lenny"
		
	actionStart: (x, y) !->
		
		@canvas.context.moveTo x, y
		# Set the line's color from the brush's color
		@canvas.context.fillStyle = "rgba(" + @color[0] + "," + @color[1] + "," + @color[2] + "," + @color[3] + ")"
		@canvas.context.font = "bold " + @radius + "px arial"
		@canvas.context.fillText "( ͡° ͜ʖ ͡°)", x, y
	
	actionEnd: !->
		return
	
	actionMove: (x, y) !->
		
		@canvas.context.fillText "( ͡° ͜ʖ ͡°)", x, y
		@canvas.action.data.push [x, y]
	
	actionMoveData: (data) !->
		for p in data
			@canvas.context.fillText "( ͡° ͜ʖ ͡°)", p[0], p[1]
		
	doAction: (data) !->
		unless data.length == 0
			@actionStart data[0][0], data[0][1]
			for p in data
				@canvas.context.fillText "( ͡° ͜ʖ ͡°)", p[0], p[1]
		
class EraserBrush extends Brush
	(radius, color, canvas) ->
		super ...
		@type = "eraser"
	
	actionStart: (x, y) !->
		corner_x = if (x - @radius) >= 0 then (x - @radius) else 0
		corner_y = if (y - @radius) >= 0 then (y - @radius) else 0
		@canvas.context.clearRect corner_x, corner_y, @radius * 2, @radius * 2
	
	actionEnd: !->
		return
	
	actionMove: (x, y) !->
		corner_x = if (x - @radius) >= 0 then (x - @radius) else 0
		corner_y = if (y - @radius) >= 0 then (y - @radius) else 0
		@canvas.context.clearRect corner_x, corner_y, @radius * 2, @radius * 2
		@canvas.action.data.push [x, y]
	
	actionMoveData: (data) !->
		for p in data
			corner_x = if (p[0] - @radius) >= 0 then (p[0] - @radius) else 0
			corner_y = if (p[1] - @radius) >= 0 then (p[1] - @radius) else 0
			@canvas.context.clearRect corner_x, corner_y, @radius * 2, @radius * 2
		
	doAction: (data) !->
		unless data.length == 0
			@actionStart data[0][0], data[0][1]
			for p in data
				corner_x = if (p[0] - @radius) >= 0 then (p[0] - @radius) else 0
				corner_y = if (p[1] - @radius) >= 0 then (p[1] - @radius) else 0
				@canvas.context.clearRect corner_x, corner_y, @radius * 2, @radius * 2

getBrush = (brushtype, radius, color, canvas) ->
	| brushtype == 'default' => new Brush radius, color, canvas
	| brushtype == 'wireframe' => new WireframeBrush radius, color, canvas
	| brushtype == 'sampler' => new ColorSamplerBrush radius, color, canvas
	| brushtype == 'lenny' => new Lenny radius, color, canvas
	| brushtype == 'eraser' => new EraserBrush radius, color, canvas


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
