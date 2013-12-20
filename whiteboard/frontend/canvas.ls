do ->
	createCanvas = (parent, width=100, height=100) ->

		canvas = {}
		canvas.node = document.createElement 'canvas'
		canvas.node.width = width
		canvas.node.height = height
		canvas.context = canvas.node.getContext '2d'
		parent.appendChild canvas.node
		canvas

	init = (container, width, height, fillColor) !->

		# History of all commands
		history = []

		#the current buffer of commands
		commands = []

		canvas = createCanvas container, width, height
		context = canvas.context

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

			# The radius of the pen
			radius = 5

			#The color of the pen
			fillColor = '#000000'

			#Draw the image
			context.fillCircle x,y,radius,fillColor
			commands.push [x,y,radius,fillColor]

			# console.log commands

		canvas.redraw = !->
		
			# Clear the screen
			context.clearRect 0, 0, canvas.node.width, canvas.node.height

			# Redraw everything in history
			[context.fillCircle y[0], y[1], y[2], y[3] for x in history for y in x]


		canvas.node.onmousedown = (e) !->

			canvas.isDrawing = yes

		canvas.node.onmouseup = (e) !->

			canvas.isDrawing = off
			history.push commands
			commands.pop
			# console.log history
			# console.log [commands]

			# commands = []
			
		window.onkeydown = (e) !->
		
			if e.ctrlKey
				canvas.ctrlActivated = true
				
		window.onkeyup = (e) !->

			switch e.keyCode
			case 90
				if canvas.ctrlActivated
					history.pop!
					canvas.redraw!

			if e.ctrlKey
				canvas.ctrlActivated = off
				
	container = document.getElementById 'canvas'

	init container, window.innerWidth - 17, window.innerHeight - 45, '#000000'
