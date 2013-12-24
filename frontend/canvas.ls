class Action
	(radius, color, coords) ->
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
		canvas.action = new Action brushRadius, fillColor, []

		#this is just in here for shits and giggles, it resides in brushes.ls

		wireframe-brush = (context, event, points) ->

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

			points

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


			# context.line-to x, y

			wireframe-brush context, e, points

			# canvas.action.coord_data.push [x,y]

			# Draw all the lines waiting to be drawn
			context.stroke!

			# console.log canvas.commands

		# CTRL-Z is horribly broken btw, you're welcome!
		canvas.redraw = !->

			# Clear the screen
			canvas.context.clearRect 0, 0, canvas.node.width, canvas.node.height
			# Redraw everything in history
			for x in canvas.history
				for y in x.coord_data
					context.line-to y[0], y[1]

		canvas.node.onmousedown = (e) !->

			canvas.isDrawing = yes

			# Move to the new position of the mouse, disable this if you want
			# to connect with the previously drawn line (maybe ctrl click?)
			points.push {x: e.clientX, y: e.clientY}
			# context.moveTo e.clientX, e.clientY

			# Radius of the pen... i think?
			context.line-width = 10

			# get rid of those nasty turns
			# context.line-join = context.line-cap = 'round'


		canvas.node.onmouseup = (e) !->

			canvas.isDrawing = off

			tempAction = (new Action canvas.action.radius,
				canvas.action.fillColor, [x for x in canvas.action.coord_data])

			canvas.history.push tempAction

			canvas.action.coord_data = []

		window.onkeydown = (e) !->

			if e.ctrlKey
				canvas.ctrlActivated = true

		window.onkeyup = (e) !->

			switch e.keyCode
			case 90
				if canvas.ctrlActivated
					canvas.history.pop!
					canvas.redraw!

			if e.ctrlKey
				canvas.ctrlActivated = false

	container = document.getElementById 'canvas'

	init container, window.innerWidth - 17, window.innerHeight - 45, '#000000', 5
