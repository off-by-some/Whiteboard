require(['menu', 'utility/color', 'utility/transformation_matrix', 'brushes/brushes', 'webrtc', 'canvas'],
	function(menu, color, transformation_matrix, brushes, webrtc, canvas)
	{
		canvas_init = canvas_script();
		canvas_init('canvas', window.innerWidth - 17, window.innerHeight - 45, 'rgba(0,0,0,1.0)', 10);
	}
);
