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
		
		# Which brush stroke radius to start out at
		canvas.brushRadius = brushRadius
		
		# History of all commands
		canvas.history = []

		# The current buffer of commands
		# canvas.commands = []
		
		# The canvas's current action
		canvas.action = new Action brushRadius, fillColor, []

		context.fillCircle = (x,y, radius, fillColor) !->

			this.fillStyle = fillColor
			this.beginPath!
			this.moveTo x,y
			this.arc x,y,radius,0, Math.PI * 2, false
			this.fill!


		canvas.node.onmousemove = (e) !->


			return unless canvas.isDrawing

			x = e.pageX - this.offsetLeft
			y = e.pageY - this.offsetTop

			#Draw the image
			canvas.context.fillCircle x,y,canvas.action.radius,canvas.action.fillColor
			canvas.action.coord_data.push [x,y]

			# console.log canvas.commands

		canvas.redraw = !->
		
			# Clear the screen
			canvas.context.clearRect 0, 0, canvas.node.width, canvas.node.height
			# Redraw everything in history
			for x in canvas.history
				for y in x.coord_data
					canvas.context.fillCircle y[0], y[1], x.radius, x.fillColor

		canvas.node.onmousedown = (e) !->

			canvas.isDrawing = yes
			
			# The radius of the pen
			canvas.action.radius = canvas.brushRadius

			#The color of the pen
			canvas.action.fillColor = '#000000'

		canvas.node.onmouseup = (e) !->

			canvas.isDrawing = off
			tempAction = new Action canvas.action.radius, canvas.action.fillColor, [x for x in canvas.action.coord_data]
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
