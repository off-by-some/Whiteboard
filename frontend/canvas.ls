# For storing information about a user; doesn't have
# much use now, but eventually it might be expanded
class User
    (id) ->
        @id = id

# Putting everything in an expression helps require.js
canvas_script = ->
    # Sets up the canvas element
    createCanvas = (parent, width=100, height=100) ->

        canvas = {}
        canvas.node = document.createElement 'canvas'
        
        canvas.layermanager = new LayerManager canvas, parent, 'layerdiv'
        
        # Eventually we'll have layering, so we handle
        # this attribute programatically
        canvas.node.style = "position: absolute; top:0; left:0"
        canvas.node.setAttribute "z-index", "1"
        canvas.node.width = width
        canvas.node.height = height
        # Default cursor is for the default brush: pencil
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

        (document.getElementById 'userlist').innerHTML = "<b>Your ID:</b><br />" + canvas.id + "<br /><br /><b>Other users:</b><hr />"

        # Which brush stroke radius to start out at
        canvas.brushRadius = brushRadius

        # History of all commands
        canvas.history = []
        
        # Keep track of how many actions we've done since last frame save
        canvas.actionCount = 0

        # The current buffer of commands
        # canvas.commands = []
        
        # The current list of users
        canvas.users = {}
        
        # The canvas's global transformation matrix
        canvas.transformation = new TransformationMatrix width, height
        
        # Initialize this user's brush
        canvas.brush = new Brush brushRadius, (Color fillColor), canvas 
        
        # Message processing
        messageFunc = (data) !->

            # message format:
            # {id:"aeuaouaeid_here", action:"action_name", data:{whatever_you_want_in_here_i_guess}}
            # console.log(e.data)
            message = data
            if message.id and message.id is not canvas.id
                # console.log "my name is " + message.id + " not " canvas.id 
                switch message.action
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
        
        joinFunc = (user_id) !->
            canvas.users[user_id] = new User user_id
            canvas.users[user_id].brush = new Brush 10, '#000000', canvas
            (document.getElementById 'userlist').innerHTML += user_id + "<hr />"
        
        partFunc = (user_id) !->
            return
        
        #testing some webrtc stuff
        canvas.rtcmanager = new WebRTCManager canvas.id, 'ws://localhost:9002/broadcast', joinFunc, partFunc, messageFunc

        # This is for when we need to render what other users have drawn
        canvas.userdraw = (user_id, x, y) !->
            temp_user = canvas.users[user_id]
            # Translate coords to our local coords
            localcoords = canvas.transformation.getCanvasCoords x, y
            # Currently there is no reason to handle the results of a tool
            unless temp_user.brush.isTool
                # First we stop the current user's drawing so paths don't get messed up
                if canvas.isDrawing
                    canvas.brush.actionEnd!
                # actionRedraw will draw everything from the other user up until this point
                temp_user.brush.actionRedraw!
                # Then we draw the current data
                temp_user.brush.actionMove localcoords[0], localcoords[1]
                # and close the path so this user can continue drawing
                temp_user.brush.actionEnd!
                # Then we restore this user's path
                if canvas.isDrawing
                    canvas.brush.actionRedraw!

        # Gets the index of the closest useable frame less than specifed index
        canvas.getLastFrameIndex = (start_index) !->
            for i from (start_index - 1) to 0 by -1
                if canvas.history[i].frame != void
                    return i
            return -1
        
        # Invalidate all frames, useful for events such as panning and scaling
        canvas.invalidateAllFrames = !->
            for i from 0 til canvas.history.length by 1
                canvas.history[i].frame = void
        
        # Get a frame
        canvas.getFrame = !->
            return canvas.context.getImageData 0, 0, canvas.node.width, canvas.node.height
        
        # Sets a frame for the latest action
        canvas.pushFrame = !->
            canvas.history[canvas.history.length - 1].frame = canvas.getFrame!
        
        # Redraw everything after the given index, optionally excluding it
        canvas.redraw = (index, exclude) !->
            frameIndex = canvas.getLastFrameIndex index
            unless frameIndex == -1
                canvas.context.putImageData canvas.history[frameIndex].frame, 0, 0
            else
                canvas.context.clearRect 0, 0, canvas.node.width, canvas.node.height
            # store the current brush
            tempBrush = canvas.brush
            # Redraw everything in history
            for i from (frameIndex + 1) til canvas.history.length by 1
                if !(exclude && (i == index))
                    tempaction = canvas.history[i]
                    canvas.brush = getBrush tempaction.data.brushtype, tempaction.data.radius, (Color tempaction.data.color), canvas
                    unless canvas.brush.isTool
                        canvas.brush.doAction tempaction.data
                    # Update any frames after the one we used
                    if tempaction.frame != void
                        tempaction.frame = canvas.context.getImageData 0, 0, canvas.node.width, canvas.node.height
            canvas.brush = tempBrush
        
        # Undo the most recent action by the specified user
        canvas.undo = (user_id) !->
            # If it's this user, then send an undo action to other users
            if user_id == 'self'
                canvas.rtcmanager.sendAll JSON.stringify {id:canvas.id, action:'undo'}
            if canvas.isDrawing
                canvas.brush.actionEnd!
            var actionIndex
            for i from (canvas.history.length - 1) to 0 by -1
                if canvas.history[i].id = user_id
                    actionIndex = i
                    break
            canvas.redraw actionIndex, true
            canvas.history.splice actionIndex, 1
            if canvas.isDrawing
                canvas.brush.actionRedraw!

        canvas.node.onmousedown = (e) !->

            canvas.isDrawing = yes
            
            # This is where actions start
            canvas.brush.actionStart e.clientX, e.clientY
            
            unless canvas.brush.isTool
                #send the action start
                canvas.rtcmanager.sendAll JSON.stringify {id:canvas.id, action:'action-start', data:(canvas.brush.getActionData!)}

        canvas.node.onmousemove = (e) !->

            return unless canvas.isDrawing

            x = e.clientX #- this.offsetLeft
            y = e.clientY #- this.offsetTop

            # console.log x, y
            
            # Process new coordinate data, draw accordingly
            canvas.brush.actionMove x, y

            # console.log canvas.commands
            
            unless canvas.brush.isTool
                canvas.rtcmanager.sendAll JSON.stringify {id:canvas.id, action:'action-data', data:(canvas.transformation.getActualCoords x, y)}

        canvas.node.onmouseup = (e) !->

            canvas.isDrawing = off

            tempframe = void
            
            # Store frames occasionaly
            if canvas.actionCount < 5
                canvas.actionCount++
            else
                canvas.actionCount = 0
                tempframe = canvas.getFrame!
            
            # Push the current action data into history so we can undo or redraw it later
            canvas.history.push {id:'self', frame:tempframe, data:(canvas.brush.getActionData!)}
            
            # End the current action
            canvas.brush.actionEnd!
            
            # Redraw to make lines prettier
            canvas.redraw (canvas.history.length - 1), false
            
            unless canvas.brush.isTool
                #send the action end
                canvas.rtcmanager.sendAll JSON.stringify {id:canvas.id, action:'action-end'}
        
        # This handles color changes, it is a piss-poor substitute for an actual MVC architecture
        canvas.doColorChange = (color) !->
            canvas.brush.color = color
            r = Math.floor ((color.getRed!) * 255.0)
            g = Math.floor ((color.getGreen!) * 255.0)
            b = Math.floor ((color.getBlue!) * 255.0)
            (document.getElementById 'color-value').value = r + "," + g + "," + b + "," + color.getAlpha!
            (document.getElementById 'alphaslider').value = "" + color.getAlpha!
            (document.getElementById 'brightnessslider').value = "" + color.getLightness!
            canvas.rtcmanager.sendAll JSON.stringify {id:canvas.id, action:'color-change', data:(color.toCSS!)}

        # We really need to do more key combos...
        window.onkeydown = (e) !->
            # Note that we have a key press
            if e.ctrlKey
                canvas.ctrlActivated = true

        window.onkeyup = (e) !->

            # See if we have a ctrl+z
            switch e.keyCode
            case 90
                if canvas.ctrlActivated
                    canvas.undo 'self'
            # If its ctrl + 0
            case 48
                if canvas.ctrlActivated
                    x = canvas.history[(canvas.history.length - 1)]
                    x.frame = canvas.context.getImageData 0, 0, canvas.node.width, canvas.node.height

                    canvas.history = []
                    canvas.history.push x
            
            # end key press
            if e.ctrlKey
                canvas.ctrlActivated = false

        window.onresize = (e) !->
            canvas.width = window.innerWidth
            canvas.height = window.innerHeight
            delta_width = Math.abs (window.innerWidth - canvas.node.width)
            delta_height = Math.abs (window.innerHeight - canvas.node.height)
            newscale = if delta_width > delta_height then (window.innerWidth / canvas.node.width) else (window.innerHeight / canvas.node.height)
            canvas.node.width = window.innerWidth
            canvas.node.height = window.innerHeight
            canvas.transformation.resetOrigin canvas.node.width, canvas.node.height
            canvas.transformation.scale newscale, newscale
            canvas.invalidateAllFrames!
            canvas.redraw (canvas.history.length - 1), false
            canvas.pushFrame!
        
        # This is called when a user types in a color value
        # Could be better, it really should happen either on blur or when enter is pressed
        (document.getElementById 'color-value').onblur = (e) !->
            canvas.doColorChange (Color 'rgba(' + this.value + ')')
        
        # Handle users typing in radius values
        # There is a better input type for this, but FF doesn't support it yet
        (document.getElementById 'radius-value').onkeypress = (e) !->
            
            canvas.brush.radius = this.value
            canvas.rtcmanager.sendAll JSON.stringify {id:canvas.id, action:'radius-change', data:this.value}

        # Downloads ftw!  I really do need to code up that svg exporter though...
        (document.getElementById 'download').onclick = (e) !->

            window.open (canvas.node.toDataURL!), 'Download'
        
        (document.getElementById 'csampler').onclick = (e) !->

            canvas.brush = new ColorSamplerBrush canvas.brush.radius, canvas.brush.color, canvas
            canvas.node.style.cursor = 'url(\"content/cursor_pipet.png\"), url(\"content/cursor_pipet.cur\"), pointer'
            canvas.rtcmanager.sendAll JSON.stringify {id:canvas.id, action:'brush-change', data:'sampler'}

        (document.getElementById 'pencil-brush').onclick = (e) !->

            canvas.brush = new Brush canvas.brush.radius, canvas.brush.color, canvas
            canvas.node.style.cursor = 'url(\"content/cursor_pencil.png\"), url(\"content/cursor_pencil.cur\"), pointer'
            canvas.rtcmanager.sendAll JSON.stringify {id:canvas.id, action:'brush-change', data:'default'}

        (document.getElementById 'wireframe-brush').onclick = (e) !->

            canvas.brush = new WireframeBrush canvas.brush.radius, canvas.brush.color, canvas
            canvas.node.style.cursor = 'url(\"content/cursor_wireframe.png\"), url(\"content/cursor_wireframe.cur\"), pointer'
            canvas.rtcmanager.sendAll JSON.stringify {id:canvas.id, action:'brush-change', data:'wireframe'}
        
        (document.getElementById 'lenny-brush').onclick = (e) !->

            canvas.brush = new Lenny canvas.brush.radius, canvas.brush.color, canvas
            canvas.node.style.cursor = 'url(\"content/cursor_pencil.png\"), url(\"content/cursor_pencil.cur\"), pointer'
            canvas.rtcmanager.sendAll JSON.stringify {id:canvas.id, action:'brush-change', data:'lenny'}
        
        (document.getElementById 'eraser-brush').onclick = (e) !->

            canvas.brush = new EraserBrush canvas.brush.radius, canvas.brush.color, canvas
            canvas.node.style.cursor = 'url(\"content/cursor_pencil.png\"), url(\"content/cursor_pencil.cur\"), pointer'
            canvas.rtcmanager.sendAll JSON.stringify {id:canvas.id, action:'brush-change', data:'eraser'}
        
        (document.getElementById 'copypaste-brush').onclick = (e) !->

            canvas.brush = new CopyPasteBrush canvas.brush.radius, canvas.brush.color, canvas
            canvas.node.style.cursor = 'url(\"content/cursor_pencil.png\"), url(\"content/cursor_pencil.cur\"), pointer'
            canvas.rtcmanager.sendAll JSON.stringify {id:canvas.id, action:'brush-change', data:'copypaste'}
            
        (document.getElementById 'developer-brush').onclick = (e) !->

            canvas.brush = new DeveloperBrush canvas.brush.radius, canvas.brush.color, canvas
            canvas.node.style.cursor = 'url(\"content/cursor_pencil.png\"), url(\"content/cursor_pencil.cur\"), pointer'
            canvas.rtcmanager.sendAll JSON.stringify {id:canvas.id, action:'brush-change', data:'developer'}
        
        (document.getElementById 'sketch-brush').onclick = (e) !->

            canvas.brush = new SketchBrush canvas.brush.radius, canvas.brush.color, canvas
            canvas.node.style.cursor = 'url(\"content/cursor_pencil.png\"), url(\"content/cursor_pencil.cur\"), pointer'
            canvas.rtcmanager.sendAll JSON.stringify {id:canvas.id, action:'brush-change', data:'sketch'}
        
        (document.getElementById 'addlayerbutton').onclick = (e) !->
            
            canvas.layermanager.createMenuEntry!
        
        # Be absoulely certain we get the right coordinates    
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
            
        (document.getElementById 'pan').onclick = (e) !->
            canvas.brush = new PanTool canvas.brush.radius, canvas.brush.color, canvas
            canvas.node.style.cursor = 'url(\"content/cursor_pipet.png\"), url(\"content/cursor_pipet.cur\"), pointer'
        (document.getElementById 'scale').onclick = (e) !->
            canvas.brush = new ScaleTool canvas.brush.radius, canvas.brush.color, canvas
            canvas.node.style.cursor = 'url(\"content/cursor_pipet.png\"), url(\"content/cursor_pipet.cur\"), pointer'
        (document.getElementById 'rotate').onclick = (e) !->
            canvas.brush = new RotateTool canvas.brush.radius, canvas.brush.color, canvas
            canvas.node.style.cursor = 'url(\"content/cursor_pipet.png\"), url(\"content/cursor_pipet.cur\"), pointer'
