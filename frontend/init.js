require(['menu', 'utility/color', 'brushes/brushes', 'webrtc', 'canvas'],
	function(menu, color, brushes, webrtc, asshole)
	{
		canvas_init = canvas_script();
		canvas_init('canvas', window.innerWidth - 17, window.innerHeight - 45, 'rgba(0,0,0,1.0)', 10);
	}
);
