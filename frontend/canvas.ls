# None of this Brush stuff should be in this file,
# but this seems to be one of the rare few languages
# where the simple act of taking a piece of code from
# one file and using it in another is so unimaginably difficult
# that it merits polluting a file like this.
# I'd really like to test this stuff tonight, so fuck it.
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
		
		r = ("0" + (p[0].toString 16)).slice -2
		g = ("0" + (p[1].toString 16)).slice -2
		b = ("0" + (p[2].toString 16)).slice -2
		
		hex = "#" + r + g + b
		@canvas.doColorChange hex
	
	actionEnd: !->
		#lel I dunno, just something ought to be here
		color = color
		
	actionMove: (x, y) !->
		@actionStart x, y
		
	doAction: (data) !->
		#I really should see about just voiding these or something...
		data[0][0]


getBrush = (brushtype, radius, color, canvas) ->
	| brushtype == 'default' => new Brush radius, color, canvas
	| brushtype == 'sampler' => new Brush radius, color, canvas



class Action
	(id, brushtype, radius, color, coords) ->
		@id = id
		@brushtype = brushtype
		@radius = radius
		@fillColor = color
		@coord_data = coords

do ->
	createCanvas = (parent, width=100, height=100) ->

		canvas = {}
		canvas.node = document.createElement 'canvas'
		canvas.node.width = width
		canvas.node.height = height
		canvas.context = canvas.node.getContext '2d'
		parent.appendChild canvas.node
		canvas

	init = (container, width, height, fillColor, brushRadius) !->

		canvas = createCanvas container, width, height
		context = canvas.context
		points = {}

		# Which brush stroke radius to start out at
		canvas.brushRadius = brushRadius

		# History of all commands
		canvas.history = []

		# The current buffer of commands
		# canvas.commands = []

		# The canvas's current action
		canvas.action = new Action 'self', 'default', brushRadius, fillColor, []
		
		canvas.brush = new Brush brushRadius, fillColor, canvas

		#this is just in here for shits and giggles, it resides in brushes.ls

		# wireframe-brush = (context, event, points) ->

		# 	points.push [x:event.clientX, y: event.clientY]
		# 	context.begin-path!

		# 	context.move-to points[0].x, points[0].y

		# 	for x in points
		# 		context.line-to points[x].x, points[x].y
		# 		nearpoint = [x-5]
		# 	if nearpoint
		# 		context.move-to nearpoint.x nearpoint.y
		# 		context.line-to points[x].x, points[x].y
		# 	context.stroke!

		# 	points
		
		#testing some websocket stuff
		canvas.connection = new WebSocket 'ws://localhost:9002/'
		canvas.connection.onopen = !->

			canvas.connection.send 'testing'
		
		# IT WORKS!

		canvas.connection.onerror = (error) !->

			console.log 'websocket dun goofed: ' + error
			
		canvas.connection.onmessage = (e) !->

			console.log 'server says: ' + e.data

		context.fillCircle = (x,y, radius, fillColor) !->

			this.fillStyle = fillColor
			this.beginPath!
			this.moveTo x,y
			this.arc x,y,radius,0, Math.PI * 2, false
			this.fill!


		canvas.node.onmousemove = (e) !->


			return unless canvas.isDrawing

			x = e.clientX #- this.offsetLeft
			y = e.clientY #- this.offsetTop
			
			canvas.brush.actionMove x, y

			canvas.action.coord_data.push [x,y]

			# console.log canvas.commands

			canvas.connection.send {'X' : x , ' Y': y}

		# TODO: Make something that keeps a frame for every 75 actions or so
		# so that we only have to draw 74 actions, instead of ALL of them
		canvas.redraw = !->

			# Clear the screen
			canvas.context.clearRect 0, 0, canvas.node.width, canvas.node.height
			# store the current brush
			tempBrush = canvas.brush
			# Redraw everything in history
			for x in canvas.history
				canvas.brush = getBrush x.brushtype, x.radius, x.fillColor, canvas
				unless canvas.brush.isTool
					canvas.brush.doAction x.coord_data
			canvas.brush = tempBrush
		
		canvas.undo = (user_id) !->

			if user_id == 'self'
				canvas.history.pop!
			else
				for i from canvas.history.length to 0 by 1
					if canvas.history[i].id = user_id
						canvas.history = canvas.history.splice i 1
				
			canvas.redraw!

		canvas.node.onmousedown = (e) !->

			canvas.isDrawing = yes
			
			canvas.brush.actionStart e.clientX, e.clientY


		canvas.node.onmouseup = (e) !->

			canvas.isDrawing = off

			tempAction = (new Action 'self', canvas.brush.type, canvas.action.radius,
				canvas.action.fillColor, [x for x in canvas.action.coord_data])

			canvas.history.push tempAction

			canvas.action.coord_data = []
			
			canvas.brush.actionEnd!
			
		# Right now, only the color sampler uses this.
		canvas.doColorChange = (color) !->
			(document.getElementById 'color-value').value = color
			canvas.action.fillColor = color
			canvas.brush.color = color

		window.onkeydown = (e) !->

			if e.ctrlKey
				canvas.ctrlActivated = true

		window.onkeyup = (e) !->

			switch e.keyCode
			case 90
				if canvas.ctrlActivated
					canvas.undo 'self'

			if e.ctrlKey
				canvas.ctrlActivated = false
				
		(document.getElementById 'color-value').onkeypress = (e) !->

			canvas.doColorChange this.value
			
		(document.getElementById 'radius-value').onkeypress = (e) !->

			canvas.action.radius = this.value
			canvas.brush.radius = this.value

		(document.getElementById 'download').onclick = (e) !->

			window.open (canvas.node.toDataURL!), 'Download'
			
		(document.getElementById 'csampler').onclick = (e) !->

			canvas.brush = new ColorSamplerBrush canvas.action.radius, canvas.action.fillColor, canvas

		(document.getElementById 'pencil-brush').onclick = (e) !->

			canvas.brush = new Brush canvas.action.radius, canvas.action.fillColor, canvas


	container = document.getElementById 'canvas'
	

	init container, window.innerWidth - 17, window.innerHeight - 45, '#000000', 10
