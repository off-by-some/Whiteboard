require(['menu', 'content/raw_data', 'utility/color', 'utility/layer_manager','utility/transformation_matrix', 'brushes/brushes', 'webrtc', 'canvas'],
	function(menu, raw_data, color, layer_manager, transformation_matrix, brushes, webrtc, canvas)
	{
		canvas_init = canvas_script();
		canvas_init('canvas', window.innerWidth - 17, window.innerHeight - 45, 'rgba(0,0,0,1.0)', 10);
	}
);
