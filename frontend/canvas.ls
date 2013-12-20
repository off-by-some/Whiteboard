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

		canvas = createCanvas container, width, height
		context = canvas.context
		
		# History of all commands
		canvas.history = []

		#the current buffer of commands
		canvas.commands = []

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
			canvas.context.fillCircle x,y,radius,fillColor
			canvas.commands.push [x,y,radius,fillColor]

			# console.log canvas.commands

		canvas.redraw = !->
		
			# Clear the screen
			canvas.context.clearRect 0, 0, canvas.node.width, canvas.node.height
			# Redraw everything in history
			for x in canvas.history
				for y in x
					canvas.context.fillCircle y[0], y[1], y[2], y[3]

		canvas.node.onmousedown = (e) !->

			canvas.isDrawing = yes

		canvas.node.onmouseup = (e) !->

			canvas.isDrawing = off
			canvas.history.push [x for x in canvas.commands]

			canvas.commands = []
			
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

	init container, window.innerWidth - 17, window.innerHeight - 45, '#000000'
