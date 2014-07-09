class LayerManager
    (canvas, width, height, canvas_div, layer_menu_div) !->
        @canvas = canvas
        @width = width
        @height = height
        @parentdiv = canvas_div
        @layer_menu = document.getElementById layer_menu_div
        @layers = {}
        @active_layer = void
        @last_z_index = 0
        @mouselayer = void
        @mouselayer = @addLayer!
        
    addLayer: !->
        newlayer = {}
        newlayer.node = document.createElement 'canvas'
        newlayer.node.style.position = "absolute"
        newlayer.node.style.top = "0"
        newlayer.node.style.left = "0"
        newlayer.node.style.visibility = "visible"
        newlayer.node.setAttribute "z-index", (@last_z_index.toString!)
        
        #Both of these are wrong now
        newlayer.node.width = @width
        newlayer.node.height = @height
        
        newlayer.name = "L_" + @last_z_index
        newlayer.UID = "layer_" + (random_string 20)
        newlayer.node.setAttribute "id", newlayer.UID
        
        newlayer.context = newlayer.node.getContext '2d'
        unless @mouselayer == void
            @parentdiv.insertBefore newlayer.node, @mouselayer.node
        else
            @parentdiv.appendChild newlayer.node
        @layers[newlayer.UID] = newlayer
        
        @last_z_index++
        
        return newlayer
    
    createMenuEntry: !->
        newlayer = @addLayer!
        entrydiv = document.createElement "div"
        entrydiv.style.height = "25px"
        entrydiv.style.background = "rgba(180,100,200,0.8)"
        entrydiv.style.border-top = "1px solid black"
        layer_name_entry = document.createElement "input"
        layer_name_entry.type = "text"
        layer_name_entry.value = newlayer.name
        layer_name_entry.size = 6
        layer_name_entry.onkeypress = (e) !~>
            newlayer.name = layer_name_entry.value
        entrydiv.appendChild layer_name_entry
        
        layer_remove_button = document.createElement "input"
        layer_remove_button.type = "button"
        layer_remove_button.value = "-"
        layer_remove_button.onclick = (e) !~>
            console.log "lol, gonna require a lot of coding before I can do that..."
        entrydiv.appendChild layer_remove_button
        
        entrydiv.onclick = (e) !~>
            if @active_layer != void
                if @active_layer.UID != newlayer.UID
                    @active_layer.menuEntry.style.background = "rgba(100, 100, 155, 0.8)"
                    entrydiv.style.background = "rgba(180, 100, 200, 0.8)"
                    @active_layer = newlayer
                else
                    entrydiv.style.background = "rgba(100, 100, 155, 0.8)"
                    @active_layer = void
            else
                entrydiv.style.background = "rgba(180, 100, 200, 0.8)"
                @active_layer = newlayer
        @layer_menu.appendChild entrydiv
        newlayer.menuEntry = entrydiv
        if @active_layer != void
            @active_layer.menuEntry.style.background = "rgba(100, 100, 155, 0.8)"
        @active_layer = newlayer
    
    setActiveLayer: (layer_uid) !->
        @active_layer = @layers[layer_uid]
    
    setLayerZIndex: (layer_uid, newZ) !->
        console.log layer_uid + ", " + newZ
        @layers[layer_uid].node.setAttribute "z-index", newZ
    
    getActiveLayer: !->
        return @active_layer
