Color = net.brehaut.Color

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
		@canvas.context.strokeStyle = @color.toCSS!
		
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
		@canvas.context.strokeStyle = @color.toCSS!
		
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
		
		hex = "rgba(" + p[0] + "," +  p[1] + "," + p[2] + "," + a + ")"
		@canvas.doColorChange (Color hex)
	
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
		@canvas.context.fillStyle = @color.toCSS!
		@canvas.context.font = "bold " + @radius + "px arial"
		@canvas.context.fillText "( ͡° ͜ʖ ͡°)", x, y
		# @canvas.action.data.push [x, y] <---- This will cause problems when actionStart is called in doAction
	
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
		@canvas.action.data.push [x, y]
	
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
			for p in data
				corner_x = if (p[0] - @radius) >= 0 then (p[0] - @radius) else 0
				corner_y = if (p[1] - @radius) >= 0 then (p[1] - @radius) else 0
				@canvas.context.clearRect corner_x, corner_y, @radius * 2, @radius * 2

class CopyPasteBrush extends Brush
	(radius, color, canvas) ->
		super ...
		@type = "copypaste"
		@imgData = void
	
	actionStart: (x, y) !->
		corner_x = if (x - @radius) >= 0 then (x - @radius) else 0
		corner_y = if (y - @radius) >= 0 then (y - @radius) else 0
		@imgData = @canvas.context.getImageData corner_x, corner_y, @radius * 2, @radius * 2
		@canvas.action.data.push [x, y]
	
	actionEnd: !->
		return
	
	actionMove: (x, y) !->
		corner_x = if (x - @radius) >= 0 then (x - @radius) else 0
		corner_y = if (y - @radius) >= 0 then (y - @radius) else 0
		@canvas.context.putImageData @imgData, corner_x, corner_y
		@canvas.action.data.push [x, y]
	
	actionMoveData: (data) !->
		for p in data
			corner_x = if (p[0] - @radius) >= 0 then (p[0] - @radius) else 0
			corner_y = if (p[1] - @radius) >= 0 then (p[1] - @radius) else 0
			@canvas.context.putImageData @imgData, corner_x, corner_y
		
	doAction: (data) !->
		unless data.length == 0
			corner_x = if (data[0][0] - @radius) >= 0 then (data[0][0] - @radius) else 0
			corner_y = if (data[0][1] - @radius) >= 0 then (data[0][1] - @radius) else 0
			@imgData = @canvas.context.getImageData corner_x, corner_y, @radius * 2, @radius * 2
			for p in data
				corner_x = if (p[0] - @radius) >= 0 then (p[0] - @radius) else 0
				corner_y = if (p[1] - @radius) >= 0 then (p[1] - @radius) else 0
				@canvas.context.putImageData @imgData, corner_x, corner_y

class SketchBrush extends Brush
	(radius, color, canvas) ->
	
		super ...
		@type = "sketch"

	actionStart: (x, y) !->
		
		@canvas.context.moveTo x, y
		# Set the line's color from the brush's color
		@canvas.context.strokeStyle = @color.toCSS!
		
		# Start a new path, because we're on a new action
		@canvas.context.beginPath!
		
		# Set the line width from the brush's current radius
		@canvas.context.line-width = @radius
		
		# get rid of those nasty turns
		@canvas.context.line-cap = 'round'
	
	actionEnd: !->
		@canvas.context.closePath!
	
	actionMove: (x, y) !->
		numpoints = @canvas.action.data.length
		if numpoints > 1
			lastpoint = @canvas.action.data[numpoints - 1]
			@canvas.context.moveTo lastpoint[0], lastpoint[1]
			@canvas.context.line-to x, y
			@canvas.context.stroke!
			@canvas.context.closePath!
			@canvas.context.strokeStyle = (@color.setAlpha ((@color.getAlpha!) / 3.0)).toCSS!
			for p in @canvas.action.data
				dx = p[0] - x;
				dy = p[1] - y;
				d = dx * dx + dy * dy;

				if d < 1000 && (!((p[0] == lastpoint[0]) && (p[1] == lastpoint[1])))
					@canvas.context.beginPath!
					@canvas.context.moveTo(x + (dx * 0.2), y + (dy * 0.2))
					@canvas.context.lineTo(p[0] - (dx * 0.2), p[1] - (dy * 0.2))
				@canvas.context.stroke!
				@canvas.context.closePath!
			@canvas.context.beginPath!
			@canvas.context.strokeStyle = @color.toCSS!
		@canvas.action.data.push [x, y]
	
	actionMoveData: (data) !->
		for p in data
			@canvas.context.line-to p[0], p[1]
		@canvas.context.stroke!
		@canvas.context.closePath!
		@canvas.context.strokeStyle = (@color.setAlpha ((@color.getAlpha!) / 3.0)).toCSS!
		for i from 1 til data.length by 1
			for p in data
				dx = p[0] - data[i][0];
				dy = p[1] - data[i][1];
				d = dx * dx + dy * dy;

				if d < 1000 && (!((p[0] == data[i-1][0]) && (p[1] == data[i-1][1])))
					@canvas.context.beginPath!
					@canvas.context.moveTo(data[i][0] + (dx * 0.2), data[i][1] + (dy * 0.2))
					@canvas.context.lineTo(p[0] - (dx * 0.2), p[1] - (dy * 0.2))
			@canvas.context.stroke!
			@canvas.context.closePath!
		@canvas.context.beginPath!
		@canvas.context.strokeStyle = @color.toCSS!

	doAction: (data) !->
		unless data.length == 0
			@actionStart data[0][0], data[0][1]
			for p in data
				@canvas.context.line-to p[0], p[1]
			@canvas.context.stroke!
			@canvas.context.closePath!
			@canvas.context.strokeStyle = (@color.setAlpha ((@color.getAlpha!) / 3.0)).toCSS!
			for i from 1 til data.length by 1
				for p in data
					dx = p[0] - data[i][0];
					dy = p[1] - data[i][1];
					d = dx * dx + dy * dy;

					if (d < 1000) && (!((p[0] == data[i-1][0]) && (p[1] == data[i-1][1])))
						@canvas.context.beginPath!
						@canvas.context.moveTo(data[i][0] + (dx * 0.2), data[i][1] + (dy * 0.2))
						@canvas.context.lineTo(p[0] - (dx * 0.2), p[1] - (dy * 0.2))
						@canvas.context.stroke!
						@canvas.context.closePath!

getBrush = (brushtype, radius, color, canvas) ->
	| brushtype == 'default' => new Brush radius, color, canvas
	| brushtype == 'wireframe' => new WireframeBrush radius, color, canvas
	| brushtype == 'sampler' => new ColorSamplerBrush radius, color, canvas
	| brushtype == 'lenny' => new Lenny radius, color, canvas
	| brushtype == 'eraser' => new EraserBrush radius, color, canvas
	| brushtype == 'copypaste' => new CopyPasteBrush radius, color, canvas
	| brushtype == 'sketch' => new SketchBrush radius, color, canvas
