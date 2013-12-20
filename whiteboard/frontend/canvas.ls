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

			#console.log commands

		canvas.node.onmousedown = (e) !->

			canvas.isDrawing = yes

		canvas.node.onmouseup = (e) !->

			canvas.isDrawing = off
			history.push commands

			commands = []

	container = document.getElementById 'canvas'

	init container, window.innerWidth - 17, window.innerHeight - 45, '#000000'
