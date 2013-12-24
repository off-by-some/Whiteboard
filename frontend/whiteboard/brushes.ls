
    wireframe-brush = (context, event, points) ->

        points.push [x:event.clientX, y: event.clientY]
        context.begin-path!

        context.move-to points[0].x, points[0].y

        for x in points
            context.line-to points[x].x, points[x].y
            nearpoint = [x-5]
            if nearpoint
                context.move-to nearpoint.x nearpoint.y
                context.line-to points[x].x, points[x].y
        context.stroke!

        points