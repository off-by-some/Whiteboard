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
		@canvas.context.strokeStyle = @color
		
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
		@canvas.context.strokeStyle = @color
		
		# Start a new path, because we're on a new action
		@canvas.context.beginPath!
		
		# Set the line width from the brush's current radius
		@canvas.context.line-width = @radius
	
	actionEnd: !->
		
		@canvas.context.closePath!
	
	actionMove: (x, y) !->
	
		@canvas.context.line-to x, y
		numpoints = @canvas.action.coord_data.length
		if numpoints >= 4
			@canvas.context.lineTo @canvas.action.coord_data[numpoints-4][0], @canvas.action.coord_data[numpoints-4][1]
		@canvas.context.stroke!
	
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
		@canvas.doColorChange hex
	
	actionEnd: !->
		return
		
	actionMove: (x, y) !->
		@actionStart x, y
	
	actionMoveData: (data) ->
		return
		
	doAction: (data) !->
		return
		
class EraserBrush extends Brush
	(radius, color, canvas) ->
		super ...
		@type = "eraser"
		@eraseBuffer = void
	
	actionStart: (x, y) !->
		@eraseBuffer = @canvas.context.createImageData @radius, @radius
		


getBrush = (brushtype, radius, color, canvas) ->
	| brushtype == 'default' => new Brush radius, color, canvas
	| brushtype == 'wireframe' => new WireframeBrush radius, color, canvas
	| brushtype == 'sampler' => new ColorSamplerBrush radius, color, canvas



class Action
	(id, brushtype, radius, color, coords) ->
		@id = id
		@brushtype = brushtype
		@radius = radius
		@fillColor = color
		@coord_data = coords

class User
	(id) ->
		@id = id

do ->
	createCanvas = (parent, width=100, height=100) ->

		canvas = {}
		canvas.node = document.createElement 'canvas'
		canvas.node.width = width
		canvas.node.height = height
		canvas.node.style.cursor = 'url(\"content/cursor_pencil.png\"), url(\"content/cursor_pencil.cur\"), pointer'
		canvas.context = canvas.node.getContext '2d'
		parent.appendChild canvas.node
		canvas

	init = (container, width, height, fillColor, brushRadius) !->

		canvas = createCanvas container, width, height
		context = canvas.context
		points = {}

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

		# The current buffer of commands
		# canvas.commands = []
		
		# The current list of users
		canvas.users = {}

		# The canvas's current action
		canvas.action = new Action 'self', 'default', brushRadius, fillColor, []
		
		canvas.brush = new Brush brushRadius, fillColor, canvas

		
		#testing some websocket stuff
		canvas.connection = new WebSocket 'ws://localhost:9002/'
		canvas.connection.onopen = !->

			canvas.connection.send JSON.stringify {id:canvas.id, action:'join'}
			return
		
		# IT WORKS!

		canvas.connection.onerror = (error) !->

			console.log 'websocket dun goofed: ' + error
			
		canvas.connection.onmessage = (e) !->

			# message format:
			# {id:"aeuaouaeid_here", action:"action_name", data:{whatever_you_want_in_here_i_guess}}
			# console.log(e.data)
			message = JSON.parse(e.data)
			if message.id
				switch message.action
				case 'join'
					canvas.users[message.id] = new User message.id
					canvas.users[message.id].brush = new Brush 10, '#000000', canvas
					canvas.users[message.id].action = new Action message.id, 'default', 10, #000000, []
				case 'action-start'
					cur_user = canvas.users[message.id]
					cur_user.action = new Action message.id, cur_user.brush.type, message.data.radius, message.data.fillColor, []
				case 'action-data'
					canvas.users[message.id].action.coord_data.push message.data
					canvas.userdraw message.id, message.data[0], message.data[1]
				case 'action-end'
					cur_user = canvas.users[message.id]
					tempAction = (new Action message.id, cur_user.brush.type, cur_user.action.radius,
					cur_user.action.fillColor, [x for x in cur_user.action.coord_data])
					canvas.history.push tempAction
				case 'undo'
					canvas.undo message.id
				case 'radius-change'
					canvas.users[message.id].brush.radius = message.data
					canvas.users[message.id].action.radius = message.data
				case 'color-change'
					canvas.users[message.id].brush.color = message.data
					canvas.users[message.id].action.fillColor = message.data
				case 'brush-change'
					cur_user = canvas.users[message.id]
					cur_user.brush = getBrush message.data, cur_user.action.radius, cur_user.action.fillColor, canvas
			else
				console.log "server says: " + e.data

		context.fillCircle = (x,y, radius, fillColor) !->

			this.fillStyle = fillColor
			this.beginPath!
			this.moveTo x,y
			this.arc x,y,radius,0, Math.PI * 2, false
			this.fill!

		canvas.userdraw = (user_id, x, y) !->
			temp_user = canvas.users[user_id]
			unless temp_user.brush.isTool
				if canvas.isDrawing
					canvas.brush.actionEnd!
				temp_user.action.coord_data.push[x,y]
				temp_user.brush.doAction temp_user.action.coord_data
				if canvas.isDrawing
					tempcoords = canvas.action.coord_data[0]
					canvas.brush.actionStart tempcoords[0], tempcoords[1]
					canvas.brush.actionMoveData canvas.action.coord_data

		canvas.node.onmousemove = (e) !->

			return unless canvas.isDrawing

			x = e.clientX #- this.offsetLeft
			y = e.clientY #- this.offsetTop
			
			canvas.brush.actionMove x, y

			canvas.action.coord_data.push [x,y]

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
				canvas.brush = getBrush x.brushtype, x.radius, x.fillColor, canvas
				unless canvas.brush.isTool
					canvas.brush.doAction x.coord_data
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
			if canvas.isDrawing
				tempcoords = canvas.action.coord_data[0]
				canvas.brush.actionStart tempcoords[0], tempcoords[1]
				canvas.brush.actionMoveData canvas.action.coord_data
				
			canvas.redraw!

		canvas.node.onmousedown = (e) !->

			canvas.isDrawing = yes
			
			canvas.brush.actionStart e.clientX, e.clientY
			
			#send the action start
			canvas.connection.send JSON.stringify {id:canvas.id, action:'action-start', data:{radius:canvas.action.radius, fillColor:canvas.action.fillColor}}


		canvas.node.onmouseup = (e) !->

			canvas.isDrawing = off

			tempAction = (new Action 'self', canvas.brush.type, canvas.action.radius,
				canvas.action.fillColor, [x for x in canvas.action.coord_data])

			canvas.history.push tempAction

			canvas.action.coord_data = []
			
			canvas.brush.actionEnd!
			
			canvas.redraw!
			
			#send the action end
			canvas.connection.send JSON.stringify {id:canvas.id, action:'action-end'}
			
		# Right now, only the color sampler uses this.
		canvas.doColorChange = (color) !->
			(document.getElementById 'color-value').value = color
			canvas.action.fillColor = color
			canvas.brush.color = color
			canvas.connection.send JSON.stringify {id:canvas.id, action:'color-change', data:color}

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
			canvas.connection.send JSON.stringify {id:canvas.id, action:'radius-change', data:this.value}

		(document.getElementById 'download').onclick = (e) !->

			window.open (canvas.node.toDataURL!), 'Download'
			
		(document.getElementById 'csampler').onclick = (e) !->

			canvas.brush = new ColorSamplerBrush canvas.action.radius, canvas.action.fillColor, canvas
			canvas.node.style.cursor = 'url(\"content/cursor_pipet.png\"), url(\"content/cursor_pipet.cur\"), pointer'
			canvas.connection.send JSON.stringify {id:canvas.id, action:'brush-change', data:'sampler'}

		(document.getElementById 'pencil-brush').onclick = (e) !->

			canvas.brush = new Brush canvas.action.radius, canvas.action.fillColor, canvas
			canvas.node.style.cursor = 'url(\"content/cursor_pencil.png\"), url(\"content/cursor_pencil.cur\"), pointer'
			canvas.connection.send JSON.stringify {id:canvas.id, action:'brush-change', data:'default'}

		(document.getElementById 'wireframe-brush').onclick = (e) !->

			canvas.brush = new WireframeBrush canvas.action.radius, canvas.action.fillColor, canvas
			canvas.node.style.cursor = 'url(\"content/cursor_wireframe.png\"), url(\"content/cursor_wireframe.cur\"), pointer'
			canvas.connection.send JSON.stringify {id:canvas.id, action:'brush-change', data:'wireframe'}


	container = document.getElementById 'canvas'
	

	init container, window.innerWidth - 17, window.innerHeight - 45, 'rgba(0,0,0,1.0)', 10
