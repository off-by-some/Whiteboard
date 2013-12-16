class Canvas
	->
		@canvas = $ \canvas .get 0
		@ctx = @canvas.get-context \2d

		$document.body
			.on \mousedown, @handler
			.on \mouseup, @handler
			.on \mousemove, @handler

	handler: (e) ~>
		if e.type is \mousedown
			# do something here
		if e.type is \mouseup
			#do something here
		if e.type is \mousemove
			#do something here
		true
