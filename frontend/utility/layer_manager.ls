class LayerMenuManager
	(canvas, menu_id) !->
		@canvas = canvas
		@menudiv = document.getElementById menu_id

class LayerManager
	(canvas, canvas_div) !->
		@canvas = canvas
		@parentdiv = canvas_div
		@layers = []
		@active_layer = void
		@last_z_index = 0
	addLayer: (width, height) !->
		newlayer = {}
		newlayer.node = document.createElement 'canvas'
        newlayer.node.style.position = "absolute"
        newlayer.node.style.top = "0"
        newlayer.node.style.left = "0"
        newlayer.node.style.visibility = "visible"
        newlayer.node.setAttribute "z-index", ((@last_z_index++).toString!)
        newlayer.node.width = width
        newlayer.node.height = height
        newlayer.node.setAttribute "id", @layers.length.toString!
        newlayer.context = canvas.node.getContext '2d'
        @parentdiv.appendChild newlayer.node
        @layers.push newlayer
        return newlayer
    
    setActiveLayer: (layernum) !->
		@active_layer = @layers[layernum]
	
	getActiveLayer: !->
		return @active_layer
