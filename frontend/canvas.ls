class Action
	(id, brushtype, radius, color, coords) ->
		@id = id
		@brushtype = brushtype
		@radius = radius
		@fillColor = color
		@data = coords

class User
	(id) ->
		@id = id

canvas_script = ->
	createCanvas = (parent, width=100, height=100) ->

		canvas = {}
		canvas.node = document.createElement 'canvas'
		canvas.node.width = width
		canvas.node.height = height
		canvas.node.style.cursor = 'url(\"content/cursor_pencil.png\"), url(\"content/cursor_pencil.cur\"), pointer'
		canvas.context = canvas.node.getContext '2d'
		parent.appendChild canvas.node
		canvas

	init = (container_id, width, height, fillColor, brushRadius) !->

		container = document.getElementById container_id
		canvas = createCanvas container, width, height
		context = canvas.context
		points = {}
		
		# The colorwheel has to be stored in an in-memory canvas for me to get data from it
		canvas.colorwheel = {}
		canvas.colorwheel.canvas = document.createElement 'canvas'
		canvas.colorwheel.context = canvas.colorwheel.canvas.getContext '2d'
		canvas.colorwheel.context.drawImage (document.getElementById 'colorwheel'), 0, 0

		# Our ID, it'll be replaced with the real one as soon as we
		# send a request to the server to get it
		canvas.id = ""
		pool = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
		for i from 0 to 20 by 1
			canvas.id += pool.charAt (Math.floor ((Math.random!) * pool.length))

		# Which brush stroke radius to start out at
		canvas.brushRadius = brushRadius

		# History of all commands
		canvas.history = []
		
		# History of frames to minimize redraw lag
		canvas.frameHistory = []
		canvas.frameHistory.push (canvas.context.getImageData 0, 0, width, height)

		# The current buffer of commands
		# canvas.commands = []
		
		# The current list of users
		canvas.users = {}
		
		canvas.brush = new Brush brushRadius, (Color fillColor), canvas
		
		#testing some websocket stuff
		canvas.connection = new WebSocket 'ws://localhost:9002/'
		canvas.connection.onopen = !->

			canvas.connection.send JSON.stringify {id:canvas.id, action:'join'}
			return
		
		# IT WORKS!

		canvas.connection.onerror = (error) !->

			# console.log 'websocket dun goofed: ' + error
			
		canvas.connection.onmessage = (e) !->

			# message format:
			# {id:"aeuaouaeid_here", action:"action_name", data:{whatever_you_want_in_here_i_guess}}
			console.log(e.data)
			message = JSON.parse(e.data)
			if message.id
				switch message.action
				case 'join'
					canvas.users[message.id] = new User message.id
					canvas.users[message.id].brush = new Brush 10, '#000000', canvas
				case 'action-start'
					cur_user = canvas.users[message.id]
					cur_user.brush.actionReset!
					cur_user.brush.setActionData message.data
				case 'action-data'
					canvas.userdraw message.id, message.data[0], message.data[1]
				case 'action-end'
					cur_user = canvas.users[message.id]
					canvas.history.push {id:message.id, data:(cur_user.brush.getActionData!)}
				case 'undo'
					canvas.undo message.id
				case 'radius-change'
					canvas.users[message.id].brush.radius = message.data
				case 'color-change'
					canvas.users[message.id].brush.color = Color message.data
				case 'brush-change'
					cur_user = canvas.users[message.id]
					cur_user.brush = getBrush message.data, cur_user.action.radius, cur_user.action.fillColor, canvas
			else
				# console.log "server says: " + e.data

		canvas.userdraw = (user_id, x, y) !->
			temp_user = canvas.users[user_id]
			unless temp_user.brush.isTool
				if canvas.isDrawing
					canvas.brush.actionEnd!
				temp_user.brush.actionRedraw!
				temp_user.brush.actionMove x, y
				temp_user.brush.actionEnd!
				if canvas.isDrawing
					canvas.brush.redraw!

		canvas.node.onmousemove = (e) !->

			return unless canvas.isDrawing

			x = e.clientX #- this.offsetLeft
			y = e.clientY #- this.offsetTop
			
			canvas.brush.actionMove x, y

			# console.log canvas.commands

			canvas.connection.send JSON.stringify {id:canvas.id, action:'action-data', data:[x,y]}

		# TODO: Make something that keeps a frame for every 75 actions or so
		# so that we only have to draw 74 actions, instead of ALL of them
		canvas.redraw = !->

			# Clear the screen
			canvas.context.clearRect 0, 0, canvas.node.width, canvas.node.height
			# store the current brush
			tempBrush = canvas.brush
			# Redraw everything in history
			for x in canvas.history
				canvas.brush = getBrush x.data.brushtype, x.data.radius, (Color x.data.color), canvas
				unless canvas.brush.isTool
					canvas.brush.doAction x.data
			canvas.brush = tempBrush
		
		canvas.undo = (user_id) !->

			if user_id == 'self'
				canvas.connection.send JSON.stringify {id:canvas.id, action:'undo'}
			if canvas.isDrawing
				canvas.brush.actionEnd!
			for i from (canvas.history.length - 1) to 0 by -1
				if canvas.history[i].id = user_id
					canvas.history.splice i, 1
					break
			canvas.redraw!
			if canvas.isDrawing
				canvas.brush.actionRedraw!

		canvas.node.onmousedown = (e) !->

			canvas.isDrawing = yes
			
			canvas.brush.actionStart e.clientX, e.clientY
			
			#send the action start
			canvas.connection.send JSON.stringify {id:canvas.id, action:'action-start', data:(canvas.brush.getActionData!)}


		canvas.node.onmouseup = (e) !->

			canvas.isDrawing = off

			canvas.history.push {id:'self', data:(canvas.brush.getActionData!)}
			
			# This needs modification
			if (canvas.history.length % 5) == 0
				canvas.frameHistory.push canvas.context.getImageData 0, 0, canvas.node.width, canvas.node.height
			
			canvas.brush.actionEnd!
			
			canvas.redraw!
			
			#send the action end
			canvas.connection.send JSON.stringify {id:canvas.id, action:'action-end'}
			
		canvas.doColorChange = (color) !->
			canvas.brush.color = color
			r = Math.floor ((color.getRed!) * 255.0)
			g = Math.floor ((color.getGreen!) * 255.0)
			b = Math.floor ((color.getBlue!) * 255.0)
			(document.getElementById 'color-value').value = r + "," + g + "," + b + "," + color.getAlpha!
			(document.getElementById 'alphaslider').value = "" + color.getAlpha!
			(document.getElementById 'brightnessslider').value = "" + color.getLightness!
			canvas.connection.send JSON.stringify {id:canvas.id, action:'color-change', data:(color.toCSS!)}

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
				
		(document.getElementById 'color-value').onblur = (e) !->
			canvas.doColorChange (Color 'rgba(' + this.value + ')')
			
		(document.getElementById 'radius-value').onkeypress = (e) !->
			
			canvas.brush.radius = this.value
			canvas.connection.send JSON.stringify {id:canvas.id, action:'radius-change', data:this.value}

		(document.getElementById 'download').onclick = (e) !->

			window.open (canvas.node.toDataURL!), 'Download'
			
		(document.getElementById 'csampler').onclick = (e) !->

			canvas.brush = new ColorSamplerBrush canvas.brush.radius, canvas.brush.color, canvas
			canvas.node.style.cursor = 'url(\"content/cursor_pipet.png\"), url(\"content/cursor_pipet.cur\"), pointer'
			canvas.connection.send JSON.stringify {id:canvas.id, action:'brush-change', data:'sampler'}

		(document.getElementById 'pencil-brush').onclick = (e) !->

			canvas.brush = new Brush canvas.brush.radius, canvas.brush.color, canvas
			canvas.node.style.cursor = 'url(\"content/cursor_pencil.png\"), url(\"content/cursor_pencil.cur\"), pointer'
			canvas.connection.send JSON.stringify {id:canvas.id, action:'brush-change', data:'default'}

		(document.getElementById 'wireframe-brush').onclick = (e) !->

			canvas.brush = new WireframeBrush canvas.brush.radius, canvas.brush.color, canvas
			canvas.node.style.cursor = 'url(\"content/cursor_wireframe.png\"), url(\"content/cursor_wireframe.cur\"), pointer'
			canvas.connection.send JSON.stringify {id:canvas.id, action:'brush-change', data:'wireframe'}
		
		(document.getElementById 'lenny-brush').onclick = (e) !->

			canvas.brush = new Lenny canvas.brush.radius, canvas.brush.color, canvas
			canvas.node.style.cursor = 'url(\"content/cursor_pencil.png\"), url(\"content/cursor_pencil.cur\"), pointer'
			canvas.connection.send JSON.stringify {id:canvas.id, action:'brush-change', data:'lenny'}
		
		(document.getElementById 'eraser-brush').onclick = (e) !->

			canvas.brush = new EraserBrush canvas.brush.radius, canvas.brush.color, canvas
			canvas.node.style.cursor = 'url(\"content/cursor_pencil.png\"), url(\"content/cursor_pencil.cur\"), pointer'
			canvas.connection.send JSON.stringify {id:canvas.id, action:'brush-change', data:'eraser'}
		
		(document.getElementById 'copypaste-brush').onclick = (e) !->

			canvas.brush = new CopyPasteBrush canvas.brush.radius, canvas.brush.color, canvas
			canvas.node.style.cursor = 'url(\"content/cursor_pencil.png\"), url(\"content/cursor_pencil.cur\"), pointer'
			canvas.connection.send JSON.stringify {id:canvas.id, action:'brush-change', data:'copypaste'}
		
		(document.getElementById 'sketch-brush').onclick = (e) !->

			canvas.brush = new SketchBrush canvas.brush.radius, canvas.brush.color, canvas
			canvas.node.style.cursor = 'url(\"content/cursor_pencil.png\"), url(\"content/cursor_pencil.cur\"), pointer'
			canvas.connection.send JSON.stringify {id:canvas.id, action:'brush-change', data:'sketch'}
			
		getCoordinates = (e, element) !->
			PosX = 0
			PosY = 0
			imgPos = [0, 0]
			if(element.offsetParent != undefined)
				while element
					imgPos[0] += element.offsetLeft
					imgPos[1] += element.offsetTop
					element = element.offsetParent
			else
				imgPos = [element.x, element.y]
			unless e
				e = window.event
			if e.pageX || e.pageY
				PosX = e.pageX
				PosY = e.pageY
			else if e.clientX || e.clientY
				PosX = e.clientX + document.body.scrollLeft + document.documentElement.scrollLeft
				PosY = e.clientY + document.body.scrollTop + document.documentElement.scrollTop
			PosX = PosX - imgPos[0]
			PosY = PosY - imgPos[1]
			return [PosX, PosY]

		(document.getElementById 'colorwheel').onclick = (e) !->
			element = document.getElementById 'colorwheel'
			imgcoords = getCoordinates e, element
			p = (canvas.colorwheel.context.getImageData imgcoords[0], imgcoords[1], 1, 1).data
		
			# getImageData gives alpha as an int from 0-255, we need a float from 0.0-1.0
			a = p[3] / 255.0
			
			hex = "rgba(" + p[0] + "," +  p[1] + "," + p[2] + "," + a + ")"
			canvas.doColorChange (Color hex)
			return
		
		(document.getElementById 'alphaslider').onchange = (e) !->
			canvas.doColorChange (canvas.brush.color.setAlpha (parseFloat this.value))
		
		(document.getElementById 'brightnessslider').onchange = (e) !->
			canvas.doColorChange (canvas.brush.color.setLightness (parseFloat this.value))
