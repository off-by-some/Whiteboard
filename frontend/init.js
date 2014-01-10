requirejs(['brushes/brushes', 'canvas'],
	function(brushes, canvas)
	{
		canvas_init = canvas_script();
		window.onload = function(){canvas_init('canvas', window.innerWidth - 17, window.innerHeight - 45, [0,0,0,1.0], 10);};
	}
);
